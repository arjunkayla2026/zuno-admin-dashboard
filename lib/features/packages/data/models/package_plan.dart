import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_status.dart';

class PackagePlan {
  const PackagePlan({
    required this.id,
    required this.rechargeAmount,
    required this.receivableAmount,
    required this.coins,
    this.offerTag = '',
    this.offerPercentage = 0,
    this.status = PackageStatus.active,
    this.isGstEnabled = false,
    this.createdAt,
    this.updatedAt,
  });

  static const double gstRate = 0.18;
  static const double coinsPerRupee = 15;
  static const double maxOfferPercentage = 100;

  static const String rechargeAmountField = 'rechargeAmount';
  static const String receivableAmountField = 'receivableAmount';
  static const String coinsField = 'coins';
  static const String offerTagField = 'offerTag';
  static const String offerPercentageField = 'offerPercentage';
  static const String packageStatusField = 'packageStatus';
  static const String isGstEnabledField = 'isGstEnabled';
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';

  final String id;
  final double rechargeAmount;
  final double receivableAmount;
  final int coins;
  final String offerTag;
  final double offerPercentage;
  final PackageStatus status;
  final bool isGstEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasOfferTag => offerTag.trim().isNotEmpty;

  bool get hasOfferPercentage => offerPercentage > 0;

  bool get isActive => status == PackageStatus.active;

  bool get isNew => id.isEmpty;

  static double payableFor(double receivable, {required bool gst}) =>
      NumberFormatter.roundAmount(
        gst ? receivable * (1 + gstRate) : receivable,
      );

  static double receivableFor(double payable, {required bool gst}) =>
      NumberFormatter.roundAmount(gst ? payable / (1 + gstRate) : payable);

  static int coinsFor(double receivable) =>
      (receivable * coinsPerRupee).round();

  static int byPrice(PackagePlan a, PackagePlan b) {
    final price = a.rechargeAmount.compareTo(b.rechargeAmount);
    return price != 0 ? price : a.id.compareTo(b.id);
  }

  factory PackagePlan.fromDocument(String id, Map<String, dynamic> data) {
    return PackagePlan(
      id: id,
      rechargeAmount: _amount(data[rechargeAmountField]),
      receivableAmount: _amount(data[receivableAmountField]),
      coins: switch (data[coinsField]) {
        final num value => value.round(),
        _ => 0,
      },
      offerTag: switch (data[offerTagField]) {
        final String tag => tag.trim(),
        _ => '',
      },
      offerPercentage: _amount(data[offerPercentageField]),
      status:
          PackageStatus.values.asNameMap()[data[packageStatusField]] ??
          PackageStatus.inactive,
      isGstEnabled: data[isGstEnabledField] == true,
      createdAt: _date(data[createdAtField]),
      updatedAt: _date(data[updatedAtField]),
    );
  }

  static double _amount(Object? value) =>
      value is num ? NumberFormatter.roundAmount(value.toDouble()) : 0;

  static DateTime? _date(Object? value) =>
      value is Timestamp ? value.toDate() : null;

  Map<String, Object?> toFields() => {
    rechargeAmountField: NumberFormatter.roundAmount(rechargeAmount),
    receivableAmountField: NumberFormatter.roundAmount(receivableAmount),
    coinsField: coins,
    offerTagField: offerTag.trim(),
    offerPercentageField: NumberFormatter.roundAmount(offerPercentage),
    packageStatusField: status.name,
    isGstEnabledField: isGstEnabled,
  };

  PackagePlan copyWith({String? id}) {
    return PackagePlan(
      id: id ?? this.id,
      rechargeAmount: rechargeAmount,
      receivableAmount: receivableAmount,
      coins: coins,
      offerTag: offerTag,
      offerPercentage: offerPercentage,
      status: status,
      isGstEnabled: isGstEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
