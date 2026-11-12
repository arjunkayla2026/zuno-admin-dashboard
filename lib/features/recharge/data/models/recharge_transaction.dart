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

class RechargeRevenue {
  const RechargeRevenue({required this.paidAmount, required this.gstAmount});

  final double paidAmount;
  final double gstAmount;

  double get netAmount => NumberFormatter.roundAmount(paidAmount - gstAmount);
}

class AdminRechargeOffer {
  const AdminRechargeOffer({required this.userId, required this.amount});

  static AdminRechargeOffer? fromDocument(Map<String, dynamic> data) {
    final userId = UserRecord.readText(data[RechargeTransaction.userIdField]);
    final amount = data[RechargeTransaction.amountFromOfferField];
    if (userId == null || amount is! num || amount <= 0) return null;
    return AdminRechargeOffer(userId: userId, amount: amount.toDouble());
  }

  final String userId;
  final double amount;
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

class AdminRechargeResult {
  const AdminRechargeResult({required this.walletBalance, required this.coins});

  factory AdminRechargeResult.fromMap(Map<Object?, Object?> data) {
    final walletBalance = data[RechargeTransaction.walletBalanceKey];
    final coins = data[RechargeTransaction.coinsKey];
    return AdminRechargeResult(
      walletBalance: walletBalance is num ? walletBalance : 0,
      coins: coins is num ? coins.round() : 0,
    );
  }

  final num walletBalance;
  final int coins;
}

class RechargeTransaction {
  const RechargeTransaction({
    required this.id,
    required this.userId,
    required this.kind,
    required this.status,
    required this.gateway,
    required this.amount,
    this.isRechargedByAdmin = false,
    this.receivedTotalAmount = 0,
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
    final isRechargedByAdmin = data[isRechargedByAdminField] == true;

    return RechargeTransaction(
      id: id,
      userId: UserRecord.readText(data[userIdField]) ?? '',
      kind: kind,
      status: _statuses[data[statusField]] ?? RechargeStatus.created,
      gateway: orderId == null
          ? RechargeGateway.admin
          : RechargeGateway.razorpay,
      amount: _readAmount(data[_amountFieldFor(kind)]),
      isRechargedByAdmin: isRechargedByAdmin,
      receivedTotalAmount: _readAmount(data[receivedTotalAmountField]),
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      orderId: orderId,
      paymentId: UserRecord.readText(data[razorpayPaymentIdField]),
    );
  }

  static const String collection = 'transactions';
  static const String coinsKey = 'coins';
  static const String walletBalanceKey = 'walletBalance';
  static const String isRechargedByAdminField = 'isRechargedByAdmin';
  static const String rechargeAmountField = 'rechargeAmount';
  static const String amountFromOfferField = 'amountFromOffer';
  static const String adminCreditAmountField = 'adminCreditAmount';
  static const String adminDebitAmountField = 'adminDebitAmount';
  static const String receivedTotalAmountField = 'receivedTotalAmount';
  static const String gstAmountField = 'gstAmount';
  static const String descriptionField = 'description';
  static const String adminUidField = 'adminUid';
  static const String packageIdField = 'packageId';
  static const String currencyField = 'currency';
  static const String failureReasonField = 'failureReason';
  static const String creditedAtField = 'creditedAt';
  static const String currency = 'INR';

  static Map<String, Object?> adminAdjustmentFields({
    required String userId,
    required bool isCredit,
    required int amount,
    required String description,
    required String adminUid,
  }) => {
    userIdField: userId,
    typeField: isCredit ? adminCreditType : adminDebitType,
    statusField: successStatus,
    packageIdField: null,
    isRechargedByAdminField: true,
    rechargeAmountField: 0,
    adminCreditAmountField: isCredit ? amount : 0,
    adminDebitAmountField: isCredit ? 0 : amount,
    gstAmountField: 0,
    amountFromOfferField: 0,
    receivedTotalAmountField: isCredit ? amount : 0,
    currencyField: currency,
    razorpayOrderIdField: null,
    razorpayPaymentIdField: null,
    failureReasonField: null,
    adminUidField: adminUid,
    descriptionField: description.isEmpty ? null : description,
    createdAtField: FieldValue.serverTimestamp(),
    creditedAtField: isCredit ? FieldValue.serverTimestamp() : null,
  };

  static const String userIdField = 'userId';
  static const String typeField = 'type';
  static const String statusField = 'status';
  static const String createdAtField = 'createdAt';
  static const String razorpayOrderIdField = 'razorpayOrderId';
  static const String razorpayPaymentIdField = 'razorpayPaymentId';

  static const String rechargeType = 'recharge';
  static const String adminCreditType = 'adminCredit';
  static const String adminDebitType = 'adminDebit';
  static const String successStatus = 'success';
  static const String failedStatus = 'failed';
  static const String pendingStatus = 'pending';

  static const List<String> rechargeTypes = [rechargeType];
  static const List<String> creditTypes = [adminCreditType];
  static const List<String> debitTypes = [adminDebitType];
  static const List<String> adjustmentTypes = [...creditTypes, ...debitTypes];
  static const List<String> completedStatuses = [successStatus];
  static const List<String> failedStatuses = [failedStatus];
  static const List<String> createdStatuses = [pendingStatus];

  static const Map<Object?, RechargeKind> _kinds = {
    rechargeType: RechargeKind.recharge,
    adminCreditType: RechargeKind.credit,
    adminDebitType: RechargeKind.debit,
  };

  static const Map<Object?, RechargeStatus> _statuses = {
    successStatus: RechargeStatus.completed,
    failedStatus: RechargeStatus.failed,
    pendingStatus: RechargeStatus.created,
  };

  final String id;
  final String userId;
  final RechargeKind kind;
  final RechargeStatus status;
  final RechargeGateway gateway;
  final double amount;
  final bool isRechargedByAdmin;
  final double receivedTotalAmount;
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

  int get coins => isCompleted
      ? PackagePlan.coinsFor(
          kind == RechargeKind.debit ? amount : receivedTotalAmount,
        )
      : 0;

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
    isRechargedByAdmin: isRechargedByAdmin,
    receivedTotalAmount: receivedTotalAmount,
    createdAt: createdAt,
    orderId: orderId,
    paymentId: paymentId,
    user: user,
  );
}
