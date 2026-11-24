import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class PayoutSummary {
  const PayoutSummary({
    this.hostCount = 0,
    this.amountEarned = 0,
    this.surgeEarnings = 0,
    this.callSeconds = 0,
    this.totalAmount = 0,
  });

  factory PayoutSummary.of(Iterable<Withdrawal> withdrawals) {
    var hostCount = 0;
    var amountEarned = 0.0;
    var surgeEarnings = 0.0;
    var callSeconds = 0;
    var totalAmount = 0.0;
    for (final withdrawal in withdrawals) {
      hostCount++;
      amountEarned += withdrawal.amountEarned;
      surgeEarnings += withdrawal.surgeEarnings;
      callSeconds += withdrawal.callSeconds;
      totalAmount += withdrawal.totalAmount;
    }
    return PayoutSummary(
      hostCount: hostCount,
      amountEarned: amountEarned,
      surgeEarnings: surgeEarnings,
      callSeconds: callSeconds,
      totalAmount: totalAmount,
    );
  }

  static const int _secondsPerMinute = 60;

  final int hostCount;

  /// Base host call earnings (`withdrawable.callEarnings`), without surge.
  final double amountEarned;

  /// Surge charge earnings (`withdrawable.surgeEarnings`).
  final double surgeEarnings;
  final int callSeconds;
  final double totalAmount;

  int get callMinutes => (callSeconds / _secondsPerMinute).round();

  double get hostCredit => totalAmount - amountEarned;

  /// The hosts' gross call earnings, base plus surge, before admin credits,
  /// admin debits and TDS.
  double get hostRevenue => amountEarned + surgeEarnings;

  PayoutSummary withoutAll(Iterable<Withdrawal> withdrawals) {
    var summary = this;
    for (final withdrawal in withdrawals) {
      summary = PayoutSummary(
        hostCount: summary.hostCount > 0 ? summary.hostCount - 1 : 0,
        amountEarned: summary.amountEarned - withdrawal.amountEarned,
        surgeEarnings: summary.surgeEarnings - withdrawal.surgeEarnings,
        callSeconds: summary.callSeconds - withdrawal.callSeconds,
        totalAmount: summary.totalAmount - withdrawal.totalAmount,
      );
    }
    return summary;
  }
}
