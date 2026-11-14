class HostEarningsTotals {
  const HostEarningsTotals({
    this.paidTotal = 0,
    this.pendingTotal = 0,
    this.adminCredit = 0,
    this.adminDebit = 0,
  });

  final double paidTotal;
  final double pendingTotal;
  final double adminCredit;
  final double adminDebit;
}
