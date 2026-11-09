import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';

enum AdminRole {
  superAdmin(AppStrings.superAdmin),
  financeAdmin(AppStrings.financeAdmin),
  supportAdmin(AppStrings.supportAdmin),
  moderator(AppStrings.moderator);

  const AdminRole(this.label);

  final String label;

  static AdminRole fromKey(Object? key) =>
      values.asNameMap()[key] ?? AdminRole.moderator;
}

class AdminAccount {
  const AdminAccount({
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    this.modules = const [],
    this.createdAt,
  });

  factory AdminAccount.fromDocument(Map<String, dynamic> data, String id) {
    final permissions = data[permissionsField];
    final createdAt = data[createdAtField];

    return AdminAccount(
      name: _text(data[nameField]) ?? id,
      email: normalizeEmail(_text(data[emailField]) ?? id),
      role: AdminRole.fromKey(data[roleField]),
      phone: _text(data[phoneField]) ?? '',
      modules: permissions is List
          ? [
              for (final item in AdminNavItem.values)
                if (permissions.contains(item.name)) item,
            ]
          : const [],
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }

  static const String nameField = 'name';
  static const String emailField = 'email';
  static const String phoneField = 'phoneNumber';
  static const String roleField = 'role';
  static const String permissionsField = 'permissions';
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
  static const int minPasswordLength = 12;

  final String name;
  final String email;
  final AdminRole role;
  final String phone;
  final List<AdminNavItem> modules;
  final DateTime? createdAt;

  static String normalizeEmail(String email) => email.trim().toLowerCase();

  static String? _text(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  static int oldestFirst(AdminAccount a, AdminAccount b) {
    final first = a.createdAt;
    final second = b.createdAt;
    if (first == null && second == null) return a.email.compareTo(b.email);
    if (first == null) return 1;
    if (second == null) return -1;
    return first.compareTo(second);
  }

  String get initials => NameFormatter.initials(name);

  bool get hasAllModules => role == AdminRole.superAdmin;

  bool get canManageAdmins => hasAllModules;

  List<AdminNavItem> get accessibleModules =>
      hasAllModules ? AdminNavItem.values : modules;

  bool canAccess(AdminNavItem module) => accessibleModules.contains(module);

  String? get homeRoute {
    for (final module in accessibleModules) {
      if (module.route case final route?) return route;
    }
    return null;
  }

  Map<String, Object?> toFields() => {
    nameField: name.trim(),
    emailField: normalizeEmail(email),
    phoneField: phone.trim(),
    roleField: role.name,
    permissionsField: [for (final module in accessibleModules) module.name],
  };

  AdminAccount copyWith({
    String? name,
    String? email,
    AdminRole? role,
    String? phone,
    List<AdminNavItem>? modules,
    DateTime? createdAt,
  }) {
    return AdminAccount(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      modules: modules ?? this.modules,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
