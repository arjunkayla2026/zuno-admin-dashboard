import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

enum UserFilter {
  all(null),
  newUsers(UserStatus.newUser),
  blocked(UserStatus.blocked),
  deletedByAdmin(UserStatus.deletedByAdmin),
  deletedByUser(UserStatus.deletedByUser);

  const UserFilter(this.status);

  final UserStatus? status;

  bool includes(AdminUser user) => status == null || user.status == status;
}

class UserManagementState {
  const UserManagementState({
    required this.users,
    this.status = LoadStatus.loaded,
    this.errorMessage,
    this.filter = UserFilter.all,
    this.query = '',
    this.page = 1,
    this.totalPages = 1,
    this.firstIndex = 0,
  });

  final List<AdminUser> users;
  final LoadStatus status;
  final String? errorMessage;
  final UserFilter filter;
  final String query;
  final int page;
  final int totalPages;
  final int firstIndex;

  UserManagementState copyWith({
    List<AdminUser>? users,
    LoadStatus? status,
    String? errorMessage,
    UserFilter? filter,
    String? query,
    int? page,
    int? totalPages,
    int? firstIndex,
  }) {
    return UserManagementState(
      users: users ?? this.users,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      firstIndex: firstIndex ?? this.firstIndex,
    );
  }
}
