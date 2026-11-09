import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/utils/date_range_matcher.dart';
import 'package:zuno_admin_dashboard/core/utils/debouncer.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/repositories/recharge_repository.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/state/recharge_state.dart';

class RechargeCubit extends Cubit<RechargeState> {
  RechargeCubit(this._repository) : super(RechargeState(today: _today()));

  final RechargeRepository _repository;
  final Debouncer _searchDebouncer = Debouncer();
  int _latestRequest = 0;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> loadRecharges() async {
    final request = ++_latestRequest;
    final today = _today();
    emit(state.copyWith(status: LoadStatus.loading, today: today, page: 1));

    final (from, until) = state.dateFilter.momentBounds(
      today: today,
      customRange: state.customRange,
    );
    final result = await _repository.fetchRecharges(from: from, until: until);
    if (isClosed || request != _latestRequest) return;

    result.match(
      (failure) => emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: failure.message,
          transactions: const [],
        ),
      ),
      (transactions) => emit(
        state.copyWith(
          status: LoadStatus.loaded,
          transactions: transactions,
          page: 1,
        ),
      ),
    );
  }

  void search(String query) => _searchDebouncer.run(() {
    if (isClosed || query == state.query) return;
    emit(state.copyWith(query: query, page: 1));
  });

  void selectDateFilter(DateRangeFilter filter) {
    if (filter == state.dateFilter) return;
    emit(state.copyWith(dateFilter: filter, page: 1));
    loadRecharges();
  }

  void selectCustomRange(DateTimeRange range) {
    emit(
      state.copyWith(
        dateFilter: DateRangeFilter.custom,
        customRange: range,
        page: 1,
      ),
    );
    loadRecharges();
  }

  void selectSource(RechargeSourceFilter filter) =>
      emit(state.copyWith(sourceFilter: filter, page: 1));

  void selectStatus(RechargeStatusFilter filter) =>
      emit(state.copyWith(statusFilter: filter, page: 1));

  void goToPage(int page) => emit(state.copyWith(page: page));

  @override
  Future<void> close() {
    _searchDebouncer.cancel();
    return super.close();
  }
}
