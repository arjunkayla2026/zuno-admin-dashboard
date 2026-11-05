import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

enum UserFilter { all, newUsers, blocked, deletedByAdmin, deletedByUser }

class UserManagementState {
  const UserManagementState({
    required this.users,
    this.filter = UserFilter.all,
    this.query = '',
    this.page = 1,
  });

  static const int pageSize = 12;

  final List<AdminUser> users;
  final UserFilter filter;
  final String query;
  final int page;

  List<AdminUser> get filteredUsers {
    final term = query.trim().toLowerCase();
    final digits = term.replaceAll(' ', '');
    return users.where((user) {
      final matchesFilter = switch (filter) {
        UserFilter.all => true,
        UserFilter.newUsers => user.status == UserStatus.newUser,
        UserFilter.blocked => user.status == UserStatus.blocked,
        UserFilter.deletedByAdmin => user.status == UserStatus.deletedByAdmin,
        UserFilter.deletedByUser => user.status == UserStatus.deletedByUser,
      };
      if (!matchesFilter) return false;
      if (term.isEmpty) return true;
      return user.name.toLowerCase().contains(term) ||
          user.userId.toLowerCase().contains(term) ||
          user.phone.replaceAll(' ', '').contains(digits);
    }).toList();
  }

  int get totalPages {
    final count = filteredUsers.length;
    if (count == 0) return 1;
    return (count / pageSize).ceil();
  }

  int get firstIndex => (page - 1) * pageSize;

  List<AdminUser> get pageUsers =>
      filteredUsers.skip(firstIndex).take(pageSize).toList();

  UserManagementState copyWith({
    List<AdminUser>? users,
    UserFilter? filter,
    String? query,
    int? page,
  }) {
    return UserManagementState(
      users: users ?? this.users,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      page: page ?? this.page,
    );
  }
}
