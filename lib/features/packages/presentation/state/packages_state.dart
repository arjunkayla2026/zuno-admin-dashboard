import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';

enum PackagesTab { packageList, couponList }

class PackagesState {
  const PackagesState({
    required this.packages,
    this.tab = PackagesTab.packageList,
  });

  final List<PackagePlan> packages;
  final PackagesTab tab;

  int get totalRecharges =>
      packages.fold(0, (sum, plan) => sum + plan.totalRecharges);

  int get nextId =>
      packages.fold(0, (max, plan) => plan.id > max ? plan.id : max) + 1;

  PackagesState copyWith({List<PackagePlan>? packages, PackagesTab? tab}) {
    return PackagesState(
      packages: packages ?? this.packages,
      tab: tab ?? this.tab,
    );
  }
}
