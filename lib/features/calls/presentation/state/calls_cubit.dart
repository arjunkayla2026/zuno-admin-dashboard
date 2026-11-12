import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/utils/date_range_matcher.dart';
import 'package:zuno_admin_dashboard/core/utils/debouncer.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';
import 'package:zuno_admin_dashboard/features/calls/data/repositories/calls_repository.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/calls_state.dart';

class CallsCubit extends Cubit<CallsState> {
  CallsCubit(this._repository) : super(CallsState(today: _today()));

  final CallsRepository _repository;
  final Debouncer _searchDebouncer = Debouncer();
  List<CallLog>? _searchPool;
  int _latestCount = 0;

  late final CursorPager<CallLog> _pager = CursorPager(
    fetch: (cursor) =>
        state.isSearching ? _searchPage(cursor) : _browsePage(cursor),
    onChanged: _publish,
  );

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  (DateTime?, DateTime?) get _bounds => state.dateFilter.momentBounds(
    today: state.today,
    customRange: state.customRange,
  );

  Future<void> loadCalls() async {
    await Future.wait([_pager.load(), _loadCount()]);
  }

  void search(String query) => _searchDebouncer.run(() {
    if (isClosed || query == state.query) return;
    emit(state.copyWith(query: query, clearMatchCount: true));
    unawaited(_pager.reset());
  });

  void selectDateFilter(DateRangeFilter filter) {
    if (filter == state.dateFilter) return;
    _applyDateRange(state.copyWith(dateFilter: filter));
  }

  void selectCustomRange(DateTimeRange range) => _applyDateRange(
    state.copyWith(dateFilter: DateRangeFilter.custom, customRange: range),
  );

  void selectStatus(CallStatusFilter filter) {
    if (filter == state.statusFilter) return;
    _applyFilters(state.copyWith(statusFilter: filter));
  }

  void selectType(CallTypeOption filter) {
    if (filter == state.typeFilter) return;
    _applyFilters(state.copyWith(typeFilter: filter));
  }

  void goToPage(int page) => _pager.goToPage(page);

  void _applyDateRange(CallsState next) {
    _searchPool = null;
    _applyFilters(next.copyWith(today: _today()));
  }

  void _applyFilters(CallsState next) {
    emit(next.copyWith(clearMatchCount: true));
    unawaited(_pager.reset());
    unawaited(_loadCount());
  }

  Future<Either<Failure, RecordPage<CallLog>>> _browsePage(Object? cursor) {
    final (from, until) = _bounds;
    return _repository.fetchPage(
      from: from,
      until: until,
      status: state.statusFilter.status?.value,
      lowBalanceOnly: state.statusFilter.lowBalanceOnly,
      callType: state.typeFilter.type?.value,
      cursor: cursor,
    );
  }

  Future<Either<Failure, RecordPage<CallLog>>> _searchPage(
    Object? cursor,
  ) async {
    final pool = await _loadSearchPool();
    return pool.map((calls) {
      final matches = calls.where(state.matchesSearch).toList();
      if (!isClosed) emit(state.copyWith(matchCount: matches.length));
      final start = cursor as int? ?? 0;
      final end = min(start + CallsRepository.pageSize, matches.length);
      return RecordPage(
        matches.sublist(start, end),
        nextCursor: end < matches.length ? end : null,
      );
    });
  }

  Future<Either<Failure, List<CallLog>>> _loadSearchPool() async {
    final cached = _searchPool;
    if (cached != null) return right(cached);

    final (from, until) = _bounds;
    final result = await _repository.fetchCallsWithUsers(
      from: from,
      until: until,
    );
    return result.map((calls) => _searchPool = calls);
  }

  Future<void> _loadCount() async {
    final request = ++_latestCount;
    emit(state.copyWith(clearTotalCount: true));
    final (from, until) = _bounds;
    final result = await _repository.count(
      from: from,
      until: until,
      status: state.statusFilter.status?.value,
      lowBalanceOnly: state.statusFilter.lowBalanceOnly,
      callType: state.typeFilter.type?.value,
    );
    if (isClosed || request != _latestCount) return;
    result.match((_) {}, (count) => emit(state.copyWith(totalCount: count)));
  }

  void _publish(CursorPageView<CallLog> view) {
    if (isClosed) return;
    emit(
      state.copyWith(
        calls: view.items,
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
