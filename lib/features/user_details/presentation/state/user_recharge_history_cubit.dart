import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_search.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/repositories/recharge_repository.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_recharge_history_state.dart';

class UserRechargeHistoryCubit extends Cubit<UserRechargeHistoryState> {
  UserRechargeHistoryCubit(this._repository, this._userId)
    : super(const UserRechargeHistoryState());

  static const Duration _searchDebounce = Duration(milliseconds: 450);

  final RechargeRepository _repository;
  final String _userId;
  RechargeSearch _applied = const RechargeSearch();
  Timer? _debounce;

  late final CursorPager<RechargeTransaction> _pager = CursorPager(
    fetch: (cursor) =>
        _repository.fetchUserHistory(_userId, search: _applied, cursor: cursor),
    onChanged: _publish,
  );

  Future<void> load() => _pager.load();

  Future<void> reload() => _pager.reset();

  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () => _apply(query));
  }

  void goToPage(int page) => _pager.goToPage(page);

  void _apply(String query) {
    final search = RechargeSearch.parse(query);
    if (search.key == _applied.key) return;

    _applied = search;
    unawaited(_pager.reset());
  }

  void _publish(CursorPageView<RechargeTransaction> view) {
    if (isClosed) return;
    emit(
      UserRechargeHistoryState(
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
    _debounce?.cancel();
    return super.close();
  }
}
