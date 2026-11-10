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
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/repositories/recharge_repository.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/state/recharge_state.dart';

class RechargeCubit extends Cubit<RechargeState> {
  RechargeCubit(this._repository) : super(RechargeState(today: _today()));

  final RechargeRepository _repository;
  final Debouncer _searchDebouncer = Debouncer();
  List<RechargeTransaction>? _searchPool;
  int _latestTotals = 0;

  late final CursorPager<RechargeTransaction> _pager = CursorPager(
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

  Future<void> loadRecharges() async {
    await Future.wait([_pager.load(), _loadTotals()]);
  }

  void search(String query) => _searchDebouncer.run(() {
    if (isClosed || query == state.query) return;
    emit(state.copyWith(query: query));
    unawaited(_pager.reset());
  });

  void selectDateFilter(DateRangeFilter filter) {
    if (filter == state.dateFilter) return;
    _applyDateRange(state.copyWith(dateFilter: filter));
  }

  void selectCustomRange(DateTimeRange range) => _applyDateRange(
    state.copyWith(dateFilter: DateRangeFilter.custom, customRange: range),
  );

  void selectSource(RechargeSourceFilter filter) {
    if (filter == state.sourceFilter) return;
    emit(state.copyWith(sourceFilter: filter));
    unawaited(_pager.reset());
  }

  void selectStatus(RechargeStatusFilter filter) {
    if (filter == state.statusFilter) return;
    emit(state.copyWith(statusFilter: filter));
    unawaited(_pager.reset());
  }

  void goToPage(int page) => _pager.goToPage(page);

  void _applyDateRange(RechargeState next) {
    emit(next.copyWith(today: _today()));
    _searchPool = null;
    unawaited(_pager.reset());
    unawaited(_loadTotals());
  }

  Future<Either<Failure, RecordPage<RechargeTransaction>>> _browsePage(
    Object? cursor,
  ) {
    final (from, until) = _bounds;
    return _repository.fetchPage(
      keep: state.matchesFilters,
      from: from,
      until: until,
      statuses: state.statusFilter.statuses,
      types: state.sourceFilter.types,
      cursor: cursor,
    );
  }

  Future<Either<Failure, RecordPage<RechargeTransaction>>> _searchPage(
    Object? cursor,
  ) async {
    final pool = await _loadSearchPool();
    return pool.map((transactions) {
      final matches = transactions.where(state.matchesSearch).toList();
      final start = cursor as int? ?? 0;
      final end = min(start + RechargeRepository.pageSize, matches.length);
      return RecordPage(
        matches.sublist(start, end),
        nextCursor: end < matches.length ? end : null,
      );
    });
  }

  Future<Either<Failure, List<RechargeTransaction>>> _loadSearchPool() async {
    final cached = _searchPool;
    if (cached != null) return right(cached);

    final (from, until) = _bounds;
    final result = await _repository.fetchRecharges(from: from, until: until);
    return result.map((transactions) => _searchPool = transactions);
  }

  Future<void> _loadTotals() async {
    final request = ++_latestTotals;
    emit(state.copyWith(clearTotals: true));
    final (from, until) = _bounds;
    final result = await _repository.fetchTotals(from: from, until: until);
    if (isClosed || request != _latestTotals) return;
    result.match((_) {}, (totals) => emit(state.copyWith(totals: totals)));
  }

  void _publish(CursorPageView<RechargeTransaction> view) {
    if (isClosed) return;
    emit(
      state.copyWith(
        transactions: view.items,
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
