import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';

class RechargePackage {
  const RechargePackage({
    required this.id,
    required this.price,
    required this.coins,
    this.bonus = 0,
    this.offerTag = '',
  });

  factory RechargePackage.fromPlan(PackagePlan plan) => RechargePackage(
    id: plan.id,
    price: plan.rechargeAmount,
    coins: plan.coins,
    bonus: PackagePlan.coinsFor(
      plan.receivableAmount * plan.offerPercentage / _percent,
    ),
    offerTag: plan.offerTag,
  );

  static const double _percent = 100;

  final String id;
  final double price;
  final int coins;
  final int bonus;
  final String offerTag;

  int get totalCoins => coins + bonus;

  bool get hasBonus => bonus > 0;

  String get priceLabel {
    final amount = NumberFormatter.rupeesAmount(price);
    return offerTag.isEmpty
        ? amount
        : AppStrings.packageLabel(amount, offerTag);
  }
}
