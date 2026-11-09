import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

enum RechargeKind { recharge, credit, debit }

enum RechargeGateway { admin, razorpay }

enum RechargeStatus { completed, failed, created }

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
    final orderId = UserRecord.readText(data[_razorpayOrderIdField]);

    return RechargeTransaction(
      id: id,
      userId: UserRecord.readText(data[userIdField]) ?? '',
      kind: _kinds[data[typeField]] ?? RechargeKind.recharge,
      status: _statuses[data[statusField]] ?? RechargeStatus.created,
      gateway: orderId == null
          ? RechargeGateway.admin
          : RechargeGateway.razorpay,
      amount: _readAmount(data[_totalAmountField] ?? data[_amountField]),
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      orderId: orderId,
      paymentId: UserRecord.readText(data[_razorpayPaymentIdField]),
    );
  }

  static const String userIdField = 'userId';
  static const String typeField = 'type';
  static const String statusField = 'status';
  static const String createdAtField = 'createdAt';
  static const String _amountField = 'amount';
  static const String _totalAmountField = 'totalAmount';
  static const String _razorpayOrderIdField = 'razorpayOrderId';
  static const String _razorpayPaymentIdField = 'razorpayPaymentId';

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
