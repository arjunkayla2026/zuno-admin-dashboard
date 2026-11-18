/// A host's admin credit and debit totals, in rupees (both positive).
class AdminAdjustmentTotals {
  const AdminAdjustmentTotals({this.credit = 0, this.debit = 0});

  final double credit;
  final double debit;

  AdminAdjustmentTotals plus({double credit = 0, double debit = 0}) =>
      AdminAdjustmentTotals(
        credit: this.credit + credit,
        debit: this.debit + debit,
      );
}
