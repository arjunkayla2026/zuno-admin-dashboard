import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';

abstract final class PackagesMockData {
  static const List<PackagePlan> packages = [
    PackagePlan(
      id: 1,
      payableAmount: 49,
      receivableAmount: 49,
      coins: 100,
      tagline: 'Starter pack',
      totalRecharges: 1840,
    ),
    PackagePlan(
      id: 2,
      payableAmount: 99,
      receivableAmount: 99,
      coins: 250,
      tagline: 'Popular',
      totalRecharges: 2615,
    ),
    PackagePlan(
      id: 3,
      payableAmount: 199,
      receivableAmount: 199,
      coins: 500,
      offer: '+50 Bonus',
      tagline: 'Best value',
      totalRecharges: 1932,
    ),
    PackagePlan(
      id: 4,
      payableAmount: 449,
      receivableAmount: 449,
      coins: 1200,
      offer: '+200 Bonus',
      tagline: 'Most loved',
      totalRecharges: 884,
    ),
    PackagePlan(
      id: 5,
      payableAmount: 999,
      receivableAmount: 999,
      coins: 2500,
      offer: '+400 Bonus',
      tagline: 'Mega pack',
      totalRecharges: 312,
    ),
  ];
}
