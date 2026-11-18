class HostEarningsTotals {
  const HostEarningsTotals({
    this.paidTotal = 0,
    this.pendingTotal = 0,
    this.openTotal = 0,
    this.deletedAccountProfit = 0,
  });

  /// `totalAmount` of the host's `success` payouts (before TDS).
  final double paidTotal;

  /// `totalAmount` of payouts frozen for payment, awaiting the admin.
  final double pendingTotal;

  /// `totalAmount` of the open payout still collecting earnings.
  final double openTotal;
  final double deletedAccountProfit;
}
