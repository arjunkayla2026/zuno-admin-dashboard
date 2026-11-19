import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/utils/date_range_matcher.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_batch_result.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_failure_reason.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_sheet_row.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';
import 'package:zuno_admin_dashboard/features/payment/data/repositories/payment_repository.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(this._repository) : super(const PaymentState());

  static const Duration _searchDebounce = Duration(milliseconds: 450);
  static const int _minimumSearchLength = 2;

  final PaymentRepository _repository;
  final Map<PaymentTab, CursorPageView<Withdrawal>> _views = {};
  final Set<PaymentTab> _stale = {};
  late final Map<PaymentTab, CursorPager<Withdrawal>> _pagers = {
    for (final tab in PaymentTab.values)
      tab: CursorPager(
        fetch: (cursor) => _fetch(tab, cursor),
        onChanged: (view) => _publish(tab, view),
      ),
  };
  CursorPager<Withdrawal>? _searchPager;
  List<Withdrawal> _searchMatches = const [];
  Timer? _debounce;
  int _searchRequest = 0;
  int _paidCountRequest = 0;
  (DateTime?, DateTime?) _paidRange = (null, null);

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final minimum = await _repository.fetchMinimumPayout();
    if (isClosed) return;
    switch (minimum) {
      case Left(value: final failure):
        emit(
          state.copyWith(
            status: LoadStatus.failure,
            errorMessage: failure.message,
          ),
        );
      case Right(value: final amount):
        emit(state.copyWith(minimumPayout: amount, minimumLoaded: true));
        unawaited(_loadCounts());
        await _show(state.tab);
    }
  }

  /// Reloads every tab and count from page 1, keeping the current tab and
  /// search, after records were added or removed outside the page's own
  /// actions.
  Future<void> refresh() async {
    if (state.batchRunning) return;
    _stale.addAll(PaymentTab.values);
    _views.clear();
    emit(state.copyWith(selected: const {}));
    if (state.isSearching && state.minimumLoaded) {
      unawaited(_loadCounts());
      return _runSearch();
    }
    await load();
  }

  Future<void> retry() async {
    if (!state.minimumLoaded) return load();
    if (state.isSearching) return _runSearch();
    await _pagers[state.tab]!.load();
  }

  void selectTab(PaymentTab tab) {
    if (tab == state.tab || state.batchRunning) return;
    emit(state.copyWith(tab: tab, page: 1, selected: const {}));
    if (!state.minimumLoaded) return;
    if (state.isSearching) {
      unawaited(_runSearch());
    } else {
      unawaited(_show(tab));
    }
  }

  void search(String query) {
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      if (isClosed || !state.minimumLoaded) return;
      emit(state.copyWith(selected: const {}));
      if (state.query.trim().length < _minimumSearchLength) {
        _searchRequest++;
        _searchPager = null;
        _searchMatches = const [];
        emit(state.copyWith(query: '', clearSearchCount: true));
        unawaited(_show(state.tab));
      } else {
        unawaited(_runSearch());
      }
    });
  }

  void selectSuccessDateFilter(DateRangeFilter filter) {
    if (filter == state.successDateFilter) return;
    _applySuccessDates(state.copyWith(successDateFilter: filter));
  }

  void selectSuccessCustomRange(DateTimeRange range) => _applySuccessDates(
    state.copyWith(
      successDateFilter: DateRangeFilter.custom,
      successCustomRange: range,
    ),
  );

  void _applySuccessDates(PaymentState next) {
    _paidRange = next.successDateFilter.momentBounds(
      today: DateUtils.dateOnly(DateTime.now()),
      customRange: next.successCustomRange,
    );
    emit(next.copyWith(clearPaidCount: true));
    _views.remove(PaymentTab.success);
    if (!state.minimumLoaded) return;
    unawaited(_loadPaidCount());
    if (state.tab != PaymentTab.success) {
      _stale.add(PaymentTab.success);
    } else if (state.isSearching) {
      unawaited(_runSearch());
    } else {
      _stale.remove(PaymentTab.success);
      unawaited(_pagers[PaymentTab.success]!.reset());
    }
  }

  bool _paidRangeIncludes(DateTime moment) {
    final (from, until) = _paidRange;
    return (from == null || !moment.isBefore(from)) &&
        (until == null || moment.isBefore(until));
  }

  void goToPage(int page) {
    (_searchPager ?? _pagers[state.tab]!).goToPage(page);
  }

  void toggleSelected(Withdrawal withdrawal) {
    if (!state.canSelect(withdrawal) || state.batchRunning) return;
    final selected = Map.of(state.selected);
    if (selected.remove(withdrawal.id) == null) {
      selected[withdrawal.id] = withdrawal;
    }
    emit(state.copyWith(selected: selected));
  }

  void setPageSelected(bool isSelected) {
    if (state.batchRunning) return;
    final selected = Map.of(state.selected);
    for (final withdrawal in state.selectableRows) {
      if (isSelected) {
        selected[withdrawal.id] = withdrawal;
      } else {
        selected.remove(withdrawal.id);
      }
    }
    emit(state.copyWith(selected: selected));
  }

  void clearSelection() {
    if (state.batchRunning) return;
    emit(state.copyWith(selected: const {}));
  }

  Future<Failure?> selectAllMatching() async {
    if (state.batchRunning || state.selectingAll) return null;
    final tab = state.tab;
    if (state.isSearching) {
      _selectFrom(_searchMatches);
      return null;
    }
    emit(state.copyWith(selectingAll: true));
    final result = await _repository.fetchAll(
      tab.status,
      minimum: state.minimumPayout,
    );
    if (isClosed) return null;
    emit(state.copyWith(selectingAll: false));
    if (state.tab != tab) return null;
    return result.match((failure) => failure, (all) {
      _selectFrom(all);
      return null;
    });
  }

  /// Loads the bank sheet rows for the selected pending payouts, or for every
  /// pending payout when nothing is selected. With [registerBeneficiaries],
  /// each host is also registered as a beneficiary first. Returns null when an
  /// export is already running or the Pending tab is not open.
  Future<Either<Failure, List<PayoutSheetRow>>?> loadSheetRows({
    bool registerBeneficiaries = false,
  }) async {
    if (state.exporting || state.tab != PaymentTab.pending) return null;
    emit(state.copyWith(exporting: true));
    final source = state.selected.isNotEmpty
        ? right<Failure, List<Withdrawal>>(state.selected.values.toList())
        : await _repository.fetchAll(
            WithdrawalStatus.pending,
            minimum: state.minimumPayout,
          );
    final rows = switch (source) {
      Left(value: final failure) => left<Failure, List<PayoutSheetRow>>(
        failure,
      ),
      Right(value: final withdrawals) =>
        registerBeneficiaries
            ? await _repository.fetchBeneficiarySheetRows(withdrawals)
            : await _repository.fetchSheetRows(withdrawals),
    };
    if (!isClosed) emit(state.copyWith(exporting: false));
    return rows;
  }

  Future<Either<Failure, PayoutBatchResult>> moveSelectedToPending() =>
      moveToPending(state.selected.values.toList());

  Future<Either<Failure, PayoutBatchResult>> markSelectedPaid() =>
      markPaid(state.selected.values.toList());

  Future<Either<Failure, PayoutBatchResult>> moveToPending(
    List<Withdrawal> withdrawals,
  ) => _runBatch(
    withdrawals,
    _repository.moveToPending,
    onDone: (moved) {
      final summary = state.summary;
      final pendingCount = state.pendingCount;
      _stale.add(PaymentTab.pending);
      emit(
        state.copyWith(
          summary: summary?.withoutAll(moved),
          pendingCount: pendingCount == null
              ? null
              : pendingCount + moved.length,
        ),
      );
      _removeFrom(PaymentTab.withdrawalList, moved);
    },
  );

  Future<Either<Failure, PayoutBatchResult>> markPaid(
    List<Withdrawal> withdrawals,
  ) => _runBatch(
    withdrawals.where((item) => item.isPending).toList(),
    _repository.completePayouts,
    onDone: (paid) {
      final pendingCount = state.pendingCount;
      final paidCount = state.paidCount;
      final countsAsPaid = _paidRangeIncludes(DateTime.now());
      _stale.add(PaymentTab.success);
      emit(
        state.copyWith(
          pendingCount: pendingCount == null
              ? null
              : (pendingCount - paid.length).clamp(0, pendingCount),
          paidCount: paidCount == null || !countsAsPaid
              ? null
              : paidCount + paid.length,
        ),
      );
      _removeFrom(PaymentTab.pending, paid);
    },
  );

  Future<Either<Failure, PayoutBatchResult>> retrySelected() =>
      retryFailed(state.selected.values.toList());

  Future<Either<Failure, PayoutBatchResult>> markFailed(
    List<Withdrawal> withdrawals,
    PayoutFailureInput failure,
  ) => _runBatch(
    withdrawals,
    (items) => _repository.markFailed(items, failure),
    onDone: (failed) {
      final pendingCount = state.pendingCount;
      final failedCount = state.failedCount;
      _stale.add(PaymentTab.failed);
      emit(
        state.copyWith(
          pendingCount: pendingCount == null
              ? null
              : (pendingCount - failed.length).clamp(0, pendingCount),
          failedCount: failedCount == null ? null : failedCount + failed.length,
        ),
      );
      _removeFrom(PaymentTab.pending, failed);
    },
  );

  Future<Either<Failure, PayoutBatchResult>> retryFailed(
    List<Withdrawal> withdrawals,
  ) => _runBatch(
    withdrawals,
    _repository.retryPayouts,
    onDone: (retried) {
      final pendingCount = state.pendingCount;
      final failedCount = state.failedCount;
      _stale.add(PaymentTab.pending);
      emit(
        state.copyWith(
          failedCount: failedCount == null
              ? null
              : (failedCount - retried.length).clamp(0, failedCount),
          pendingCount: pendingCount == null
              ? null
              : pendingCount + retried.length,
        ),
      );
      _removeFrom(PaymentTab.failed, retried);
    },
  );

  Future<Either<Failure, PayoutBatchResult>> _runBatch(
    List<Withdrawal> withdrawals,
    Future<Either<Failure, PayoutBatchResult>> Function(List<Withdrawal>)
    send, {
    required void Function(List<Withdrawal> done) onDone,
  }) async {
    if (withdrawals.isEmpty) return right(const PayoutBatchResult());
    if (state.batchRunning) return right(const PayoutBatchResult());
    emit(state.copyWith(batchRunning: true));
    final result = await send(withdrawals);
    if (isClosed) return result;
    emit(state.copyWith(batchRunning: false));
    result.match((_) {}, (batch) {
      if (!batch.hasSuccess) return;
      final doneIds = {for (final item in batch.succeeded) item.id};
      emit(
        state.copyWith(
          selected: {
            for (final entry in state.selected.entries)
              if (!doneIds.contains(entry.key)) entry.key: entry.value,
          },
        ),
      );
      onDone(batch.succeeded);
      unawaited(_loadCounts());
    });
    return result;
  }

  void _removeFrom(PaymentTab tab, List<Withdrawal> done) {
    final doneIds = {for (final item in done) item.id};
    Withdrawal? remove(Withdrawal item) =>
        doneIds.contains(item.id) ? null : item;
    _pagers[tab]!.update(remove);
    if (state.tab == tab && _searchPager != null) {
      _searchMatches = [
        for (final item in _searchMatches)
          if (!doneIds.contains(item.id)) item,
      ];
      final searchCount = state.searchCount;
      emit(
        state.copyWith(
          searchCount: searchCount == null
              ? null
              : (searchCount - done.length).clamp(0, searchCount),
        ),
      );
      _searchPager?.update(remove);
    }
  }

  void _selectFrom(List<Withdrawal> candidates) {
    final selected = Map.of(state.selected);
    var added = 0;
    for (final withdrawal in candidates) {
      if (added >= PaymentRepository.selectAllLimit) break;
      if (!state.canSelect(withdrawal)) continue;
      selected[withdrawal.id] = withdrawal;
      added++;
    }
    emit(state.copyWith(selected: selected));
  }

  Future<Either<Failure, RecordPage<Withdrawal>>> _fetch(
    PaymentTab tab,
    Object? cursor,
  ) {
    return switch (tab) {
      PaymentTab.withdrawalList => _repository.fetchOpenPage(
        minimum: state.minimumPayout,
        cursor: cursor,
      ),
      PaymentTab.pending => _repository.fetchPendingPage(cursor: cursor),
      PaymentTab.success => _repository.fetchPaidPage(
        cursor: cursor,
        from: _paidRange.$1,
        until: _paidRange.$2,
      ),
      PaymentTab.failed => _repository.fetchFailedPage(cursor: cursor),
    };
  }

  Future<void> _show(PaymentTab tab) {
    final pager = _pagers[tab]!;
    if (_stale.remove(tab)) return pager.reset();
    final view = _views[tab];
    if (view != null) emit(state.withView(view));
    return pager.load();
  }

  void _publish(PaymentTab tab, CursorPageView<Withdrawal> view) {
    _views[tab] = view;
    if (isClosed || state.isSearching || state.tab != tab) return;
    emit(state.withView(view));
  }

  Future<void> _loadCounts() async {
    final minimum = state.minimumPayout;
    final (summary, pendingCount, failedCount, _) = await (
      _repository.fetchSummary(minimum),
      _repository.countPending(),
      _repository.countFailed(),
      _loadPaidCount(),
    ).wait;
    if (isClosed) return;
    emit(
      state.copyWith(
        summary: summary.toNullable(),
        pendingCount: pendingCount.toNullable(),
        failedCount: failedCount.toNullable(),
      ),
    );
  }

  Future<void> _loadPaidCount() async {
    final request = ++_paidCountRequest;
    final (from, until) = _paidRange;
    final count = await _repository.countPaid(from: from, until: until);
    if (isClosed || request != _paidCountRequest) return;
    emit(state.copyWith(paidCount: count.toNullable()));
  }

  Future<void> _runSearch() async {
    final request = ++_searchRequest;
    final tab = state.tab;
    emit(state.copyWith(status: LoadStatus.loading, clearSearchCount: true));
    final result = await _repository.search(
      state.query,
      minimum: state.minimumPayout,
      status: tab.status,
      paidFrom: _paidRange.$1,
      paidUntil: _paidRange.$2,
    );
    if (isClosed || request != _searchRequest) return;

    switch (result) {
      case Left(value: final failure):
        emit(
          state.copyWith(
            status: LoadStatus.failure,
            errorMessage: failure.message,
          ),
        );
      case Right(value: final matches):
        _searchMatches = matches;
        emit(state.copyWith(searchCount: matches.length));
        final pager = CursorPager<Withdrawal>(
          fetch: (cursor) async => right(
            RecordPages.local(
              cursor is LocalPageCursor<Withdrawal>
                  ? cursor.remaining
                  : _searchMatches,
              RecordPageQuery.pageSize,
            ),
          ),
          onChanged: (view) {
            if (!isClosed && request == _searchRequest) {
              emit(state.withView(view));
            }
          },
        );
        _searchPager = pager;
        await pager.load();
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
