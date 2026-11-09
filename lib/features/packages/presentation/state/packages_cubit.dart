import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/features/packages/data/mock/packages_mock_data.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/state/packages_state.dart';

class PackagesCubit extends Cubit<PackagesState> {
  PackagesCubit()
    : super(const PackagesState(packages: PackagesMockData.packages));

  void selectTab(PackagesTab tab) => emit(state.copyWith(tab: tab));

  void addPackage(PackagePlan plan) => emit(
    state.copyWith(
      packages: [
        ...state.packages,
        plan.copyWith(id: state.nextId),
      ],
    ),
  );

  void updatePackage(PackagePlan plan) => emit(
    state.copyWith(
      packages: [
        for (final current in state.packages)
          current.id == plan.id ? plan : current,
      ],
    ),
  );
}
