import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/core/data/search_keywords.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/mock/host_mock_data.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/call_pricing.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/repositories/host_management_repository.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_management_state.dart';

class HostManagementCubit extends Cubit<HostManagementState> {
  HostManagementCubit(this._repository)
    : super(
        const HostManagementState(
          hosts: [],
          pricing: HostMockData.pricing,
          status: LoadStatus.loading,
        ),
      );

  static const Duration _searchDebounce = Duration(milliseconds: 450);

  final HostManagementRepository _repository;
  String? _appliedTerm;
  HostFilter _appliedFilter = HostFilter.today;
  Timer? _debounce;

  late final CursorPager<AdminHost> _pager = CursorPager(
    fetch: (cursor) => _repository.fetchHosts(
      status: _appliedFilter.status,
      onlyNew: _appliedFilter.onlyNew,
      term: _appliedTerm,
      cursor: cursor,
    ),
    onChanged: _publish,
  );

  Future<void> loadHosts() => _pager.load();

  void search(String query) {
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, _applyQuery);
  }

  void selectFilter(HostFilter filter) {
    emit(state.copyWith(filter: filter));
    _applyQuery();
  }

  void goToPage(int page) => _pager.goToPage(page);

  void updatePricing(CallPricing pricing) =>
      emit(state.copyWith(pricing: pricing));

  void replaceHost(AdminHost replacement) => _pager.update(
    (host) => host.hostId != replacement.hostId
        ? host
        : _appliedFilter.includes(replacement)
        ? replacement
        : null,
  );

  void _applyQuery() {
    _debounce?.cancel();
    final term = SearchKeywords.normalizeTerm(state.query);
    if (term == _appliedTerm && state.filter == _appliedFilter) return;

    final needsNewPages =
        term != _appliedTerm ||
        state.filter.status != _appliedFilter.status ||
        state.filter.onlyNew != _appliedFilter.onlyNew;
    _appliedTerm = term;
    _appliedFilter = state.filter;
    if (needsNewPages) _pager.reset();
  }

  void _publish(CursorPageView<AdminHost> view) {
    if (isClosed) return;
    emit(
      state.copyWith(
        hosts: view.items,
        status: view.status,
        errorMessage: view.error,
        page: view.page,
        totalPages: view.totalPages,
        firstIndex: view.firstIndex,
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
