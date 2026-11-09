import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/repositories/user_management_repository.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_management_state.dart';

class UserManagementCubit extends Cubit<UserManagementState> {
  UserManagementCubit(this._repository)
    : super(const UserManagementState(users: [], status: LoadStatus.loading));

  final UserManagementRepository _repository;

  Future<void> loadUsers() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final result = await _repository.fetchUsers();
    if (isClosed) return;

    result.match(
      (failure) => emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (users) => emit(
        state.copyWith(status: LoadStatus.loaded, users: users, page: 1),
      ),
    );
  }

  void search(String query) => emit(state.copyWith(query: query, page: 1));

  void selectFilter(UserFilter filter) =>
      emit(state.copyWith(filter: filter, page: 1));

  void goToPage(int page) => emit(state.copyWith(page: page));

  void replaceUser(AdminUser replacement) {
    final users = [
      for (final current in state.users)
        current.userId == replacement.userId ? replacement : current,
    ];
    _showUsers(users);
    refreshUsers();
  }

  Future<void> refreshUsers() async {
    final result = await _repository.fetchUsers();
    if (isClosed) return;
    result.match((_) {}, _showUsers);
  }

  void _showUsers(List<AdminUser> users) {
    final updated = state.copyWith(users: users);
    emit(
      updated.page > updated.totalPages
          ? updated.copyWith(page: updated.totalPages)
          : updated,
    );
  }
}
