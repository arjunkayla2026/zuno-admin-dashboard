import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/state/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(DashboardState(today: _dayOf((clock ?? DateTime.now)())));

  final DashboardRepository _repository;
  final DateTime Function() _clock;

  static DateTime _dayOf(DateTime moment) =>
      DateTime(moment.year, moment.month, moment.day);

  Future<void> load() => _loadAll();

  Future<bool> refresh() async {
    if (state.refreshing) return true;
    emit(
      state
          .withRange(
            today: _dayOf(_clock()),
            dateFilter: state.dateFilter,
          )
          .copyWith(refreshing: true),
    );
    final succeeded = await _loadAll(force: true);
    if (!isClosed) emit(state.copyWith(refreshing: false));
    return succeeded;
  }

  Future<bool> _loadAll({bool force = false}) async {
    final results = await Future.wait([
      _loadRevenue(force: force),
      _loadCallRevenue(force: force),
      _loadMessageRevenue(force: force),
      _loadAccounts(force: force),
      _loadRecent(force: force),
      _loadCallStats(force: force),
    ]);
    return results.every((succeeded) => succeeded);
  }

  static const Duration _defaultCustomSpan = Duration(days: 13);

  void selectDateFilter(DateRangeFilter filter) {
    if (filter == state.dateFilter) return;
    final today = _dayOf(_clock());
    if (filter == DateRangeFilter.custom) {
      selectCustomRange(
        state.customRange ??
            DateTimeRange(
              start: today.subtract(_defaultCustomSpan),
              end: today,
            ),
      );
      return;
    }
    emit(state.withRange(today: today, dateFilter: filter));
    load();
  }

  void setCustomStart(DateTime date) {
    final range = state.customRange;
    if (range == null) return;
    selectCustomRange(DateTimeRange(start: date, end: range.end));
  }

  void setCustomEnd(DateTime date) {
    final range = state.customRange;
    if (range == null) return;
    selectCustomRange(DateTimeRange(start: range.start, end: date));
  }

  void selectCustomRange(DateTimeRange range) {
    if (state.dateFilter == DateRangeFilter.custom &&
        range == state.customRange) {
      return;
    }
    emit(
      state.withRange(
        today: _dayOf(_clock()),
        dateFilter: DateRangeFilter.custom,
        customRange: range,
      ),
    );
    load();
  }

  void retryRevenue() {
    if (state.revenueStatus == LoadStatus.failure) _loadRevenue();
    if (state.callRevenueStatus == LoadStatus.failure) _loadCallRevenue();
    if (state.messageRevenueStatus == LoadStatus.failure) {
      _loadMessageRevenue();
    }
  }

  void retryAccounts() => _loadAccounts();

  void retryRecent() => _loadRecent();

  void retryCallStats() => _loadCallStats();

  Future<bool> _loadRevenue({bool force = false}) => _loadSection(
    force: force,
    cached: _repository.cachedRevenue,
    fetch: _repository.fetchRevenue,
    loading: (state) => state.copyWith(revenueStatus: LoadStatus.loading),
    loaded: (state, revenue) =>
        state.copyWith(revenueStatus: LoadStatus.loaded, revenue: revenue),
    failed: (state, message) => state.copyWith(
      revenueStatus: LoadStatus.failure,
      revenueError: message,
    ),
  );

  Future<bool> _loadCallRevenue({bool force = false}) => _loadSection(
    force: force,
    cached: _repository.cachedCallRevenue,
    fetch: _repository.fetchCallRevenue,
    loading: (state) => state.copyWith(callRevenueStatus: LoadStatus.loading),
    loaded: (state, revenue) => state.copyWith(
      callRevenueStatus: LoadStatus.loaded,
      callRevenue: revenue,
    ),
    failed: (state, message) => state.copyWith(
      callRevenueStatus: LoadStatus.failure,
      callRevenueError: message,
    ),
  );

  Future<bool> _loadMessageRevenue({bool force = false}) => _loadSection(
    force: force,
    cached: _repository.cachedMessageRevenue,
    fetch: _repository.fetchMessageRevenue,
    loading: (state) =>
        state.copyWith(messageRevenueStatus: LoadStatus.loading),
    loaded: (state, revenue) => state.copyWith(
      messageRevenueStatus: LoadStatus.loaded,
      messageRevenue: revenue,
    ),
    failed: (state, message) => state.copyWith(
      messageRevenueStatus: LoadStatus.failure,
      messageRevenueError: message,
    ),
  );

  Future<bool> _loadAccounts({bool force = false}) => _loadSection(
    force: force,
    cached: _repository.cachedAccounts,
    fetch: _repository.fetchAccounts,
    loading: (state) => state.copyWith(accountsStatus: LoadStatus.loading),
    loaded: (state, accounts) =>
        state.copyWith(accountsStatus: LoadStatus.loaded, accounts: accounts),
    failed: (state, message) => state.copyWith(
      accountsStatus: LoadStatus.failure,
      accountsError: message,
    ),
  );

  Future<bool> _loadRecent({bool force = false}) => _loadSection(
    force: force,
    cached: _repository.cachedRecentRecharges,
    fetch: _repository.fetchRecentRecharges,
    loading: (state) => state.copyWith(recentStatus: LoadStatus.loading),
    loaded: (state, recharges) => state.copyWith(
      recentStatus: LoadStatus.loaded,
      recentRecharges: recharges,
    ),
    failed: (state, message) =>
        state.copyWith(recentStatus: LoadStatus.failure, recentError: message),
  );

  Future<bool> _loadCallStats({bool force = false}) => _loadSection(
    force: force,
    cached: _repository.cachedCallStatistics,
    fetch: _repository.fetchCallStatistics,
    loading: (state) => state.copyWith(callsStatus: LoadStatus.loading),
    loaded: (state, stats) =>
        state.copyWith(callsStatus: LoadStatus.loaded, callStats: stats),
    failed: (state, message) =>
        state.copyWith(callsStatus: LoadStatus.failure, callsError: message),
  );

  Future<bool> _loadSection<T>({
    required bool force,
    required T? Function(DashboardRange range) cached,
    required Future<Either<Failure, T>> Function(
      DashboardRange range, {
      bool force,
    })
    fetch,
    required DashboardState Function(DashboardState state) loading,
    required DashboardState Function(DashboardState state, T value) loaded,
    required DashboardState Function(DashboardState state, String message)
    failed,
  }) async {
    final range = state.range;
    final cachedValue = cached(range);
    emit(cachedValue == null ? loading(state) : loaded(state, cachedValue));

    final result = await fetch(range, force: force);
    if (isClosed || state.range != range) return true;
    switch (result) {
      case Left(value: final failure) when cachedValue == null:
        emit(failed(state, failure.message));
      case Right(value: final value) when !identical(value, cachedValue):
        emit(loaded(state, value));
      default:
        break;
    }
    return result.isRight();
  }
}
