import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';
import 'package:zuno_admin_dashboard/features/packages/data/repositories/packages_repository.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/state/packages_state.dart';

class PackagesCubit extends Cubit<PackagesState> {
  PackagesCubit(this._repository)
    : super(const PackagesState(packages: [], status: LoadStatus.loading));

  final PackagesRepository _repository;

  Future<void> loadPackages() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final result = await _repository.fetchPackages();
    if (isClosed) return;

    result.match(
      (failure) => emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (packages) =>
          emit(state.copyWith(status: LoadStatus.loaded, packages: packages)),
    );
  }

  void selectTab(PackagesTab tab) => emit(state.copyWith(tab: tab));

  Future<String?> savePackage(PackagePlan plan) async {
    final result = await _repository.savePackage(plan);
    return result.match((failure) => failure.message, (saved) {
      if (!isClosed) {
        emit(state.copyWith(packages: _withPackage(saved)));
      }
      return null;
    });
  }

  List<PackagePlan> _withPackage(PackagePlan saved) {
    final exists = state.packages.any((plan) => plan.id == saved.id);
    return [
      for (final plan in state.packages) plan.id == saved.id ? saved : plan,
      if (!exists) saved,
    ]..sort(PackagePlan.byPrice);
  }
}
