import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
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
  final List<List<AdminUser>> _pages = [];
  final List<Object?> _cursors = [];
  String? _appliedTerm;
  UserFilter _appliedFilter = UserFilter.all;
  Timer? _debounce;
  int _latestRequest = 0;
  bool _isLoading = false;

  bool get _hasNext => _cursors.isNotEmpty && _cursors.last != null;

  int get _knownPages => max(1, _pages.length + (_hasNext ? 1 : 0));

  Future<void> loadUsers() async {
    if (_isLoading || state.status == LoadStatus.loaded) return;
    await _load();
  }

  void search(String query) {
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, _applyQuery);
  }

  void selectFilter(UserFilter filter) {
    emit(state.copyWith(filter: filter));
    _applyQuery();
  }

  void goToPage(int page) {
    if (_isLoading || page == state.page) return;
    if (page <= _pages.length) {
      _show(page);
    } else if (page == _pages.length + 1 && _hasNext) {
      _load();
    }
  }

  void replaceUser(AdminUser replacement) {
    for (var index = 0; index < _pages.length; index++) {
      _pages[index] = [
        for (final user in _pages[index])
          if (user.id != replacement.id)
            user
          else if (_appliedFilter.includes(replacement))
            replacement,
      ];
    }

    Object? droppedCursor;
    final emptied = _pages.indexWhere((page) => page.isEmpty);
    if (emptied >= 0) {
      _pages.removeAt(emptied);
      droppedCursor = _cursors.removeAt(emptied);
      if (emptied > 0) _cursors[emptied - 1] = droppedCursor;
    }

    if (_isLoading || state.status != LoadStatus.loaded) return;
    if (_pages.isEmpty && droppedCursor != null) {
      _load();
      return;
    }
    final page = min(state.page, _knownPages);
    if (page > _pages.length && _hasNext) {
      _load();
    } else {
      _show(page);
    }
  }

  void _applyQuery() {
    _debounce?.cancel();
    final term = SearchKeywords.normalizeTerm(state.query);
    if (term == _appliedTerm && state.filter == _appliedFilter) return;

    _appliedTerm = term;
    _appliedFilter = state.filter;
    _pages.clear();
    _cursors.clear();
    _load();
  }

  Future<void> _load() async {
    final request = ++_latestRequest;
    _isLoading = true;
    emit(
      state.copyWith(
        status: LoadStatus.loading,
        users: const [],
        page: _pages.length + 1,
      ),
    );

    final result = await _repository.fetchUsers(
      status: _appliedFilter.status,
      term: _appliedTerm,
      cursor: _cursors.isEmpty ? null : _cursors.last,
    );
    if (isClosed || request != _latestRequest) return;
    _isLoading = false;

    result.match(
      (failure) => emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (loaded) {
        if (loaded.items.isEmpty) {
          if (_cursors.isNotEmpty) _cursors.last = null;
          _show(max(1, _pages.length));
          return;
        }
        _pages.add(loaded.items);
        _cursors.add(loaded.nextCursor);
        _show(_pages.length);
      },
    );
  }

  void _show(int page) {
    emit(
      state.copyWith(
        status: LoadStatus.loaded,
        users: _pages.isEmpty ? const [] : _pages[page - 1],
        page: page,
        totalPages: _knownPages,
        firstIndex: _pages
            .take(page - 1)
            .fold<int>(0, (total, rows) => total + rows.length),
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
