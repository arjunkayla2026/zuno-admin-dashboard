import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class PayoutSummary {
  const PayoutSummary({
    this.hostCount = 0,
    this.amountEarned = 0,
    this.callSeconds = 0,
    this.totalAmount = 0,
  });

  static const int _secondsPerMinute = 60;

  final int hostCount;
  final double amountEarned;
  final int callSeconds;
  final double totalAmount;

  int get callMinutes => (callSeconds / _secondsPerMinute).round();

  double get hostCredit => totalAmount - amountEarned;

  PayoutSummary withoutAll(Iterable<Withdrawal> withdrawals) {
    var summary = this;
    for (final withdrawal in withdrawals) {
      summary = PayoutSummary(
        hostCount: summary.hostCount > 0 ? summary.hostCount - 1 : 0,
        amountEarned: summary.amountEarned - withdrawal.amountEarned,
        callSeconds: summary.callSeconds - withdrawal.callSeconds,
        totalAmount: summary.totalAmount - withdrawal.totalAmount,
      );
    }
    return summary;
  }
}
