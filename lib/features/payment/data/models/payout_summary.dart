import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
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

  double get hostCredit =>
      NumberFormatter.roundAmount(totalAmount - amountEarned);

  PayoutSummary without(Withdrawal withdrawal) => PayoutSummary(
    hostCount: hostCount > 0 ? hostCount - 1 : 0,
    amountEarned: NumberFormatter.roundAmount(
      amountEarned - withdrawal.amountEarned,
    ),
    callSeconds: callSeconds - withdrawal.callSeconds,
    totalAmount: NumberFormatter.roundAmount(
      totalAmount - withdrawal.totalAmount,
    ),
  );
}
