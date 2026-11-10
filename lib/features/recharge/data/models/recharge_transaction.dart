import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

enum RechargeKind { recharge, credit, debit }

enum RechargeGateway { admin, razorpay }

enum RechargeStatus { completed, failed, created }

class RechargeTotals {
  const RechargeTotals({
    required this.rechargeCount,
    required this.rechargeAmount,
    required this.creditAmount,
    required this.debitAmount,
  });

  final int rechargeCount;
  final double rechargeAmount;
  final double creditAmount;
  final double debitAmount;
}

class UserRechargeSummary {
  const UserRechargeSummary({
    required this.totalRecharge,
    required this.receivedCoins,
  });

  factory UserRechargeSummary.fromTransactions(
    Iterable<RechargeTransaction> transactions,
  ) {
    var totalRecharge = 0.0;
    var receivedCoins = 0;
    for (final transaction in transactions) {
      if (!transaction.isCompleted) continue;
      if (transaction.kind == RechargeKind.recharge) {
        totalRecharge += transaction.amount;
      }
      receivedCoins += transaction.kind == RechargeKind.debit
          ? -transaction.coins
          : transaction.coins;
    }
    return UserRechargeSummary(
      totalRecharge: NumberFormatter.roundAmount(totalRecharge),
      receivedCoins: receivedCoins,
    );
  }

  final double totalRecharge;
  final int receivedCoins;
}

class RechargeTransaction {
  const RechargeTransaction({
    required this.id,
    required this.userId,
    required this.kind,
    required this.status,
    required this.gateway,
    required this.amount,
    this.createdAt,
    this.orderId,
    this.paymentId,
    this.user,
  });

  factory RechargeTransaction.fromDocument(
    String id,
    Map<String, dynamic> data,
  ) {
    final createdAt = data[createdAtField];
    final orderId = UserRecord.readText(data[razorpayOrderIdField]);
    final kind = _kinds[data[typeField]] ?? RechargeKind.recharge;

    return RechargeTransaction(
      id: id,
      userId: UserRecord.readText(data[userIdField]) ?? '',
      kind: kind,
      status: _statuses[data[statusField]] ?? RechargeStatus.created,
      gateway: orderId == null
          ? RechargeGateway.admin
          : RechargeGateway.razorpay,
      amount: _readAmount(data[_amountFieldFor(kind)]),
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      orderId: orderId,
      paymentId: UserRecord.readText(data[razorpayPaymentIdField]),
    );
  }

  static const String collection = 'transactions';
  static const String coinsField = 'coins';
  static const String rechargeAmountField = 'rechargeAmount';
  static const String amountFromOfferField = 'amountFromOffer';
  static const String adminCreditAmountField = 'adminCreditAmount';
  static const String adminDebitAmountField = 'adminDebitAmount';
  static const String receivedTotalAmountField = 'receivedTotalAmount';
  static const String descriptionField = 'description';
  static const String adminUidField = 'adminUid';

  static Map<String, Object?> adminAdjustmentFields({
    required String userId,
    required bool isCredit,
    required int amount,
    required String description,
    required String adminUid,
  }) => {
    userIdField: userId,
    typeField: isCredit ? creditTypes.first : debitTypes.first,
    statusField: completedStatuses.first,
    rechargeAmountField: 0,
    amountFromOfferField: 0,
    adminCreditAmountField: isCredit ? amount : 0,
    adminDebitAmountField: isCredit ? 0 : amount,
    receivedTotalAmountField: isCredit ? amount : 0,
    coinsField: PackagePlan.coinsFor(amount.toDouble()),
    if (description.isNotEmpty) descriptionField: description,
    adminUidField: adminUid,
    createdAtField: FieldValue.serverTimestamp(),
  };

  static const String userIdField = 'userId';
  static const String typeField = 'type';
  static const String statusField = 'status';
  static const String createdAtField = 'createdAt';
  static const String razorpayOrderIdField = 'razorpayOrderId';
  static const String razorpayPaymentIdField = 'razorpayPaymentId';

  static const List<String> rechargeTypes = ['recharge'];
  static const List<String> creditTypes = ['credit', 'adminCredit'];
  static const List<String> debitTypes = ['debit', 'adminDebit'];
  static const List<String> adjustmentTypes = [...creditTypes, ...debitTypes];
  static const List<String> completedStatuses = ['success', 'completed'];
  static const List<String> failedStatuses = ['failed'];
  static const List<String> createdStatuses = ['pending', 'created'];

  static const Map<Object?, RechargeKind> _kinds = {
    'recharge': RechargeKind.recharge,
    'credit': RechargeKind.credit,
    'adminCredit': RechargeKind.credit,
    'debit': RechargeKind.debit,
    'adminDebit': RechargeKind.debit,
  };

  static const Map<Object?, RechargeStatus> _statuses = {
    'success': RechargeStatus.completed,
    'completed': RechargeStatus.completed,
    'failed': RechargeStatus.failed,
    'pending': RechargeStatus.created,
    'created': RechargeStatus.created,
  };

  final String id;
  final String userId;
  final RechargeKind kind;
  final RechargeStatus status;
  final RechargeGateway gateway;
  final double amount;
  final DateTime? createdAt;
  final String? orderId;
  final String? paymentId;
  final AdminUser? user;

  static double _readAmount(Object? value) =>
      value is num ? value.toDouble() : 0;

  static String _amountFieldFor(RechargeKind kind) => switch (kind) {
    RechargeKind.recharge => rechargeAmountField,
    RechargeKind.credit => adminCreditAmountField,
    RechargeKind.debit => adminDebitAmountField,
  };

  static int newestFirst(RechargeTransaction a, RechargeTransaction b) {
    final first = a.createdAt;
    final second = b.createdAt;
    if (first == null && second == null) return a.id.compareTo(b.id);
    if (first == null) return 1;
    if (second == null) return -1;
    return second.compareTo(first);
  }

  String get userName => user?.name ?? AppStrings.emptyValue;

  String get phone => user?.phone ?? AppStrings.emptyValue;

  String get initials => NameFormatter.initials(userName);

  int get avatarIndex =>
      user?.avatarIndex ??
      userId.codeUnits.fold(0, (total, unit) => total + unit);

  String get displayOrderId => orderId ?? id;

  bool get isCompleted => status == RechargeStatus.completed;

  int get coins => isCompleted ? PackagePlan.coinsFor(amount) : 0;

  bool get isAdminRecharge =>
      kind == RechargeKind.recharge && gateway == RechargeGateway.admin;

  bool get isAdminAdjustment =>
      kind == RechargeKind.credit || kind == RechargeKind.debit;

  bool get isGatewayPayment =>
      kind == RechargeKind.recharge && gateway == RechargeGateway.razorpay;

  RechargeTransaction withUser(AdminUser? user) => RechargeTransaction(
    id: id,
    userId: userId,
    kind: kind,
    status: status,
    gateway: gateway,
    amount: amount,
    createdAt: createdAt,
    orderId: orderId,
    paymentId: paymentId,
    user: user,
  );
}
