class PackagePlan {
  const PackagePlan({
    required this.id,
    required this.payableAmount,
    required this.receivableAmount,
    required this.coins,
    required this.tagline,
    this.offer = '',
    this.totalRecharges = 0,
    this.gstEnabled = false,
  });

  static const double gstRate = 0.18;

  final int id;
  final int payableAmount;
  final int receivableAmount;
  final int coins;
  final String offer;
  final String tagline;
  final int totalRecharges;
  final bool gstEnabled;

  bool get hasOffer => offer.trim().isNotEmpty;

  static int payableFor(int receivable, {required bool gst}) =>
      gst ? (receivable * (1 + gstRate)).round() : receivable;

  static int receivableFor(int payable, {required bool gst}) =>
      gst ? (payable / (1 + gstRate)).round() : payable;

  PackagePlan copyWith({int? id}) {
    return PackagePlan(
      id: id ?? this.id,
      payableAmount: payableAmount,
      receivableAmount: receivableAmount,
      coins: coins,
      offer: offer,
      tagline: tagline,
      totalRecharges: totalRecharges,
      gstEnabled: gstEnabled,
    );
  }
}
