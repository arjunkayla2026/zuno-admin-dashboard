import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';

enum PackagesTab { packageList, couponList }

class PackagesState {
  const PackagesState({
    required this.packages,
    this.status = LoadStatus.loaded,
    this.errorMessage,
    this.tab = PackagesTab.packageList,
  });

  final List<PackagePlan> packages;
  final LoadStatus status;
  final String? errorMessage;
  final PackagesTab tab;

  int get activeCount => packages.where((plan) => plan.isActive).length;

  PackagesState copyWith({
    List<PackagePlan>? packages,
    LoadStatus? status,
    String? errorMessage,
    PackagesTab? tab,
  }) {
    return PackagesState(
      packages: packages ?? this.packages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      tab: tab ?? this.tab,
    );
  }
}
