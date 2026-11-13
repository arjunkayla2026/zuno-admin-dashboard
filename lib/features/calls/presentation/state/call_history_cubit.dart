import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/core/enums/call_filter.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_participant.dart';
import 'package:zuno_admin_dashboard/features/calls/data/repositories/calls_repository.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/call_history_state.dart';

class CallHistoryCubit extends Cubit<CallHistoryState> {
  CallHistoryCubit(this._repository, this._participant)
    : super(CallHistoryState.startingOn(DateUtils.dateOnly(DateTime.now())));

  final CallsRepository _repository;
  final CallParticipant _participant;
  int _latestMatchCount = 0;

  late final CursorPager<CallLog> _pager = CursorPager(
    fetch: (cursor) {
      final (from, until) = state.bounds;
      return _repository.fetchPage(
        participant: _participant,
        from: from,
        until: until,
        callType: state.callType?.value,
        cursor: cursor,
      );
    },
    onChanged: _publish,
  );

  Future<void> load() async {
    await Future.wait([
      _pager.load(),
      if (state.matchCount == null) _loadMatchCount(),
      if (state.totalCount == null) _loadTotalCount(),
    ]);
  }

  void selectType(CallTypeFilter filter) {
    if (filter == state.typeFilter) return;
    _apply(state.copyWith(typeFilter: filter));
  }

  void selectDateMode(CallDateMode mode) {
    if (mode == state.dateMode) return;
    _apply(state.copyWith(dateMode: mode));
  }

  void setSingleDate(DateTime date) {
    final day = DateUtils.dateOnly(date);
    if (day == state.singleDate) return;
    _apply(state.copyWith(singleDate: day));
  }

  void setRangeStart(DateTime date) {
    final day = DateUtils.dateOnly(date);
    if (day == state.rangeStart) return;
    _apply(state.copyWith(rangeStart: day));
  }

  void setRangeEnd(DateTime date) {
    final day = DateUtils.dateOnly(date);
    if (day == state.rangeEnd) return;
    _apply(state.copyWith(rangeEnd: day));
  }

  void goToPage(int page) => _pager.goToPage(page);

  void _apply(CallHistoryState next) {
    emit(next.copyWith(clearMatchCount: true));
    unawaited(_pager.reset());
    unawaited(_loadMatchCount());
  }

  Future<void> _loadMatchCount() async {
    final request = ++_latestMatchCount;
    final (from, until) = state.bounds;
    final result = await _repository.count(
      participant: _participant,
      from: from,
      until: until,
      callType: state.callType?.value,
    );
    if (isClosed || request != _latestMatchCount) return;
    result.match((_) {}, (count) => emit(state.copyWith(matchCount: count)));
  }

  Future<void> _loadTotalCount() async {
    final result = await _repository.count(participant: _participant);
    if (isClosed) return;
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
}
