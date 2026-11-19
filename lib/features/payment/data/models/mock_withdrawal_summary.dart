import 'package:zuno_admin_dashboard/core/data/payout_settings.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

/// One mock host's `hostDetails.hostEarnings.totalWithdrawel` next to the sum
/// of its `success` payout records, so a double count shows as a mismatch.
class MockHostTotals {
  const MockHostTotals({
    required this.hostId,
    required this.hostName,
    required this.hostUserId,
    required this.recordedWithdrawn,
    required this.successRecordsTotal,
  });

  final String hostId;
  final String hostName;
  final String hostUserId;
  final double recordedWithdrawn;
  final double successRecordsTotal;

  bool get matches =>
      (recordedWithdrawn - successRecordsTotal).abs() <
      PayoutSettings.amountTolerance;
}

class MockWithdrawalSummary {
  const MockWithdrawalSummary({
    this.withdrawals = const [],
    this.hosts = const [],
  });

  final List<Withdrawal> withdrawals;
  final List<MockHostTotals> hosts;

  bool get isEmpty => withdrawals.isEmpty && hosts.isEmpty;

  Iterable<Withdrawal> _withStatus(WithdrawalStatus status) =>
      withdrawals.where((item) => item.status == status);

  static double _sum(Iterable<Withdrawal> items) =>
      items.fold(0, (total, item) => total + item.totalAmount);

  List<Withdrawal> get pending =>
      _withStatus(WithdrawalStatus.pending).toList()
        ..sort((a, b) => a.settledDate.compareTo(b.settledDate));

  int get pendingCount => _withStatus(WithdrawalStatus.pending).length;

  double get pendingAmount => _sum(_withStatus(WithdrawalStatus.pending));

  int get successCount => _withStatus(WithdrawalStatus.success).length;

  double get successAmount => _sum(_withStatus(WithdrawalStatus.success));

  int get rejectedCount => _withStatus(WithdrawalStatus.failed).length;

  double get rejectedAmount => _sum(_withStatus(WithdrawalStatus.failed));

  /// Every mock withdrawal request: pending, successful and rejected.
  double get totalAmount => pendingAmount + successAmount + rejectedAmount;

  /// The mock hosts' stored `totalWithdrawel`, added up.
  double get totalWithdrawn =>
      hosts.fold(0, (total, host) => total + host.recordedWithdrawn);
}
