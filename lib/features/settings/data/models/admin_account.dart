import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';

enum AdminRole { superAdmin, financeAdmin, supportAdmin, moderator }

class AdminAccount {
  const AdminAccount({
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    this.modules = const [],
  });

  final String name;
  final String email;
  final AdminRole role;
  final String phone;
  final List<AdminNavItem> modules;

  String get initials => NameFormatter.initials(name);

  bool get hasAllModules => role == AdminRole.superAdmin;

  AdminAccount copyWith({
    String? name,
    String? email,
    AdminRole? role,
    String? phone,
    List<AdminNavItem>? modules,
  }) {
    return AdminAccount(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      modules: modules ?? this.modules,
    );
  }
}
