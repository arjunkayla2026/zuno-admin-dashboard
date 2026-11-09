class RechargeRecord {
  const RechargeRecord({
    required this.date,
    required this.time,
    required this.type,
    required this.amount,
    required this.receivedCoins,
    required this.orderId,
    this.adminCredit,
    this.adminDebit,
    this.paymentId,
  });

  final DateTime date;
  final String time;
  final String type;
  final String amount;
  final String? adminCredit;
  final String? adminDebit;
  final String receivedCoins;
  final String? paymentId;
  final String orderId;
}
