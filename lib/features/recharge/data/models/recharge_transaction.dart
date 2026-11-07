import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';

enum RechargeKind { recharge, credit, debit }

enum RechargeGateway { admin, razorpay }

enum RechargeStatus { completed, failed, created }

class RechargeTransaction {
  const RechargeTransaction({
    required this.dateTime,
    required this.userName,
    required this.userId,
    required this.phone,
    required this.kind,
    required this.amount,
    required this.coins,
    required this.orderId,
    required this.gateway,
    required this.avatarIndex,
    this.paymentId,
    this.status = RechargeStatus.completed,
  });

  final DateTime dateTime;
  final String userName;
  final String userId;
  final String phone;
  final RechargeKind kind;
  final int amount;
  final int coins;
  final String? paymentId;
  final String orderId;
  final RechargeGateway gateway;
  final int avatarIndex;
  final RechargeStatus status;

  String get initials => NameFormatter.initials(userName);

  bool get isAdminRecharge =>
      kind == RechargeKind.recharge && gateway == RechargeGateway.admin;

  bool get isAdminAdjustment =>
      kind == RechargeKind.credit || kind == RechargeKind.debit;

  bool get isGatewayPayment => gateway == RechargeGateway.razorpay;
}
