import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/core/data/search_keywords.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/repositories/user_management_repository.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_management_state.dart';

class UserManagementCubit extends Cubit<UserManagementState> {
  UserManagementCubit(this._repository)
    : super(const UserManagementState(users: [], status: LoadStatus.loading));

  static const Duration _searchDebounce = Duration(milliseconds: 450);

  final UserManagementRepository _repository;
  String? _appliedTerm;
  UserFilter _appliedFilter = UserFilter.all;
  Timer? _debounce;

  late final CursorPager<AdminUser> _pager = CursorPager(
    fetch: (cursor) => _repository.fetchUsers(
      status: _appliedFilter.status,
      term: _appliedTerm,
      cursor: cursor,
    ),
    onChanged: _publish,
  );

  Future<void> loadUsers() => _pager.load();

  void search(String query) {
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, _applyQuery);
  }

  void selectFilter(UserFilter filter) {
    emit(state.copyWith(filter: filter));
    _applyQuery();
  }

  void goToPage(int page) => _pager.goToPage(page);

  void replaceUser(AdminUser replacement) => _pager.update(
    (user) => user.id != replacement.id
        ? user
        : _appliedFilter.includes(replacement)
        ? replacement
        : null,
  );

  void _applyQuery() {
    _debounce?.cancel();
    final term = SearchKeywords.normalizeTerm(state.query);
    if (term == _appliedTerm && state.filter == _appliedFilter) return;

    _appliedTerm = term;
    _appliedFilter = state.filter;
    _pager.reset();
  }

  void _publish(CursorPageView<AdminUser> view) {
    if (isClosed) return;
    emit(
      state.copyWith(
        users: view.items,
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
