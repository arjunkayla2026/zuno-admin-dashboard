import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/mock/user_mock_data.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_management_state.dart';

class UserManagementCubit extends Cubit<UserManagementState> {
  UserManagementCubit() : super(UserManagementState(users: UserMockData.users));

  void search(String query) => emit(state.copyWith(query: query, page: 1));

  void selectFilter(UserFilter filter) =>
      emit(state.copyWith(filter: filter, page: 1));

  void goToPage(int page) => emit(state.copyWith(page: page));

  void replaceUser(AdminUser replacement) {
    final users = [
      for (final current in state.users)
        current.userId == replacement.userId ? replacement : current,
    ];
    final updated = state.copyWith(users: users);
    emit(
      updated.page > updated.totalPages
          ? updated.copyWith(page: updated.totalPages)
          : updated,
    );
  }
}
