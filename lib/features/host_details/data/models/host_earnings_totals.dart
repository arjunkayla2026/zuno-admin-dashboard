class HostEarningsTotals {
  const HostEarningsTotals({
    this.paidTotal = 0,
    this.pendingTotal = 0,
    this.failedTotal = 0,
    this.openTotal = 0,
    this.deletedAccountProfit = 0,
  });

  /// `totalAmount` of the host's `success` payouts (before TDS).
  final double paidTotal;

  /// `totalAmount` of payouts frozen for payment, awaiting the admin.
  final double pendingTotal;

  /// `totalAmount` of payouts whose transfer failed, awaiting a retry.
  final double failedTotal;

  /// `totalAmount` of the open payout still collecting earnings.
  final double openTotal;
  final double deletedAccountProfit;

  /// Moved to payment but not paid yet: pending plus failed payouts.
  double get awaitingPaymentTotal => pendingTotal + failedTotal;
}
