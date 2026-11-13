import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/utils/debouncer.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/user_report.dart';
import 'package:zuno_admin_dashboard/features/reports/data/repositories/reports_repository.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/state/reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit(this._repository) : super(ReportsState(today: _today()));

  final ReportsRepository _repository;
  final Debouncer _searchDebouncer = Debouncer();
  int _latestCount = 0;

  late final CursorPager<UserReport> _pager = CursorPager(
    fetch: (cursor) =>
        _repository.fetchPage(state.reportsQuery, cursor: cursor),
    onChanged: _publish,
  );

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> loadReports() async {
    await Future.wait([_pager.load(), _loadCount()]);
  }

  void search(String query) => _searchDebouncer.run(() {
    if (isClosed || query == state.query) return;
    _applyFilters(state.copyWith(query: query));
  });

  void selectDateFilter(DateRangeFilter filter) {
    if (filter == state.dateFilter) return;
    _applyFilters(state.copyWith(dateFilter: filter));
  }

  void selectCustomRange(DateTimeRange range) => _applyFilters(
    state.copyWith(dateFilter: DateRangeFilter.custom, customRange: range),
  );

  void selectType(ReportTypeFilter filter) {
    if (filter == state.typeFilter) return;
    _applyFilters(state.copyWith(typeFilter: filter));
  }

  void selectReporter(ReporterFilter filter) {
    if (filter == state.reporterFilter) return;
    _applyFilters(state.copyWith(reporterFilter: filter));
  }

  void goToPage(int page) => _pager.goToPage(page);

  void _applyFilters(ReportsState next) {
    emit(next.copyWith(today: _today()));
    unawaited(_pager.reset());
    unawaited(_loadCount());
  }

  Future<void> _loadCount() async {
    final request = ++_latestCount;
    emit(state.copyWith(clearTotalCount: true));
    final result = await _repository.count(state.reportsQuery);
    if (isClosed || request != _latestCount) return;
    result.match((_) {}, (count) => emit(state.copyWith(totalCount: count)));
  }

  void _publish(CursorPageView<UserReport> view) {
    if (isClosed) return;
    emit(
      state.copyWith(
        reports: view.items,
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
    _searchDebouncer.cancel();
    return super.close();
  }
}
