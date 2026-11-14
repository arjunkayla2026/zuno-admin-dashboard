import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
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
    if (tab == state.tab) return;
    emit(state.copyWith(tab: tab, page: 1));
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
      if (state.query.trim().length < _minimumSearchLength) {
        _searchRequest++;
        _searchPager = null;
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

  Future<Either<Failure, Withdrawal>> markPaid(Withdrawal withdrawal) async {
    final result = await _repository.completePayout(withdrawal);
    if (isClosed) return result;
    result.match((_) {}, (paid) {
      Withdrawal? replace(Withdrawal item) =>
          item.id == withdrawal.id ? paid : item;
      Withdrawal? remove(Withdrawal item) =>
          item.id == withdrawal.id ? null : item;

      _stale.add(PaymentTab.success);
      final summary = state.summary;
      final paidCount = state.paidCount;
      emit(
        state.copyWith(
          summary: summary?.without(withdrawal),
          paidCount: paidCount == null ? null : paidCount + 1,
        ),
      );
      _pagers[PaymentTab.pending]!.update(remove);
      _pagers[PaymentTab.withdrawalList]!.update(replace);
      _searchPager?.update(state.tab == PaymentTab.pending ? remove : replace);
    });
    return result;
  }

  Future<Either<Failure, RecordPage<Withdrawal>>> _fetch(
    PaymentTab tab,
    Object? cursor,
  ) {
    final minimum = state.minimumPayout;
    return switch (tab) {
      PaymentTab.withdrawalList => _repository.fetchListPage(
        minimum: minimum,
        cursor: cursor,
      ),
      PaymentTab.pending => _repository.fetchEligiblePage(
        minimum: minimum,
        cursor: cursor,
      ),
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
    final (summary, paidCount) = await (
      _repository.fetchSummary(minimum),
      _repository.countPaid(),
    ).wait;
    if (isClosed) return;
    emit(
      state.copyWith(
        summary: summary.toNullable(),
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
      includePending: tab != PaymentTab.success,
      includePaid: tab != PaymentTab.pending,
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
        emit(state.copyWith(searchCount: matches.length));
        final pager = CursorPager<Withdrawal>(
          fetch: (cursor) async => right(
            RecordPages.local(
              cursor is LocalPageCursor<Withdrawal>
                  ? cursor.remaining
                  : matches,
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
