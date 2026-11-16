import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_batch_result.dart';
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
        _show(state.tab);
    }
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
      _show(tab);
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
        _show(state.tab);
      } else {
        unawaited(_runSearch());
      }
    });
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
    withdrawals,
    _repository.completePayouts,
    onDone: (paid) {
      final pendingCount = state.pendingCount;
      final paidCount = state.paidCount;
      _stale.add(PaymentTab.success);
      emit(
        state.copyWith(
          pendingCount: pendingCount == null
              ? null
              : (pendingCount - paid.length).clamp(0, pendingCount),
          paidCount: paidCount == null ? null : paidCount + paid.length,
        ),
      );
      _removeFrom(PaymentTab.pending, paid);
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
      PaymentTab.success => _repository.fetchPaidPage(cursor: cursor),
    };
  }

  void _show(PaymentTab tab) {
    final pager = _pagers[tab]!;
    if (_stale.remove(tab)) {
      unawaited(pager.reset());
      return;
    }
    final view = _views[tab];
    if (view != null) emit(state.withView(view));
    unawaited(pager.load());
  }

  void _publish(PaymentTab tab, CursorPageView<Withdrawal> view) {
    _views[tab] = view;
    if (isClosed || state.isSearching || state.tab != tab) return;
    emit(state.withView(view));
  }

  Future<void> _loadCounts() async {
    final minimum = state.minimumPayout;
    final (summary, pendingCount, paidCount) = await (
      _repository.fetchSummary(minimum),
      _repository.countPending(),
      _repository.countPaid(),
    ).wait;
    if (isClosed) return;
    emit(
      state.copyWith(
        summary: summary.toNullable(),
        pendingCount: pendingCount.toNullable(),
        paidCount: paidCount.toNullable(),
      ),
    );
  }

  Future<void> _runSearch() async {
    final request = ++_searchRequest;
    final tab = state.tab;
    emit(state.copyWith(status: LoadStatus.loading, clearSearchCount: true));
    final result = await _repository.search(
      state.query,
      minimum: state.minimumPayout,
      status: tab.status,
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
