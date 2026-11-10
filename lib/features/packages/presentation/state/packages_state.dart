import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';

enum PackagesTab { packageList, couponList }

class PackagesState {
  const PackagesState({
    required this.packages,
    this.status = LoadStatus.loaded,
    this.errorMessage,
    this.tab = PackagesTab.packageList,
    this.page = 1,
    this.totalPages = 1,
    this.firstIndex = 0,
    this.totalCount,
    this.activeCount,
  });

  final List<PackagePlan> packages;
  final LoadStatus status;
  final String? errorMessage;
  final PackagesTab tab;
  final int page;
  final int totalPages;
  final int firstIndex;
  final int? totalCount;
  final int? activeCount;

  PackagesState copyWith({
    List<PackagePlan>? packages,
    LoadStatus? status,
    String? errorMessage,
    PackagesTab? tab,
    int? page,
    int? totalPages,
    int? firstIndex,
    int? totalCount,
    int? activeCount,
  }) {
    return PackagesState(
      packages: packages ?? this.packages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      tab: tab ?? this.tab,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      firstIndex: firstIndex ?? this.firstIndex,
      totalCount: totalCount ?? this.totalCount,
      activeCount: activeCount ?? this.activeCount,
    );
  }
}
