import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';
import 'package:zuno_admin_dashboard/features/packages/data/repositories/packages_repository.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/state/packages_state.dart';

class PackagesCubit extends Cubit<PackagesState> {
  PackagesCubit(this._repository)
    : super(const PackagesState(packages: [], status: LoadStatus.loading));

  final PackagesRepository _repository;

  late final CursorPager<PackagePlan> _pager = CursorPager(
    fetch: (cursor) => _repository.fetchPackages(cursor: cursor),
    onChanged: _publish,
  );

  Future<void> loadPackages() async {
    await Future.wait([_pager.load(), _loadCounts()]);
  }

  Future<void> _loadCounts() async {
    final result = await _repository.fetchCounts();
    if (isClosed) return;
    result.match((_) {}, (counts) {
      emit(
        state.copyWith(totalCount: counts.total, activeCount: counts.active),
      );
    });
  }

  void selectTab(PackagesTab tab) => emit(state.copyWith(tab: tab));

  void goToPage(int page) => _pager.goToPage(page);

  Future<String?> savePackage(PackagePlan plan) async {
    final previous = state.packages
        .where((item) => item.id == plan.id)
        .firstOrNull;
    final result = await _repository.savePackage(plan);
    return result.match((failure) => failure.message, (saved) {
      if (isClosed) return null;
      _adjustCounts(plan, previous, saved);
      if (previous != null && previous.payableAmount == saved.payableAmount) {
        _pager.update((item) => item.id == saved.id ? saved : item);
      } else {
        unawaited(_pager.reset());
      }
      return null;
    });
  }

  void _adjustCounts(
    PackagePlan plan,
    PackagePlan? previous,
    PackagePlan saved,
  ) {
    final total = state.totalCount;
    final active = state.activeCount;
    emit(
      state.copyWith(
        totalCount: total == null ? null : total + (plan.isNew ? 1 : 0),
        activeCount: active == null
            ? null
            : active +
                  (saved.isActive ? 1 : 0) -
                  (previous?.isActive == true ? 1 : 0),
      ),
    );
  }

  void _publish(CursorPageView<PackagePlan> view) {
    if (isClosed) return;
    emit(
      state.copyWith(
        packages: view.items,
        status: view.status,
        errorMessage: view.error,
        page: view.page,
        totalPages: view.totalPages,
        firstIndex: view.firstIndex,
      ),
    );
  }
}
