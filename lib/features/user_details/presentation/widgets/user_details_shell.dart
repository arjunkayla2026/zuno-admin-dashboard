import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_shell.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_empty_state.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/mock/user_mock_data.dart';

class UserDetailsShell extends StatelessWidget {
  const UserDetailsShell({super.key, required this.child});

  UserDetailsShell.message({super.key, required String message})
    : child = AppEmptyState(
        icon: Icons.person_outline_rounded,
        title: AppStrings.userDetails,
        message: message,
      );

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      selectedItem: AdminNavItem.userManagement,
      title: AppStrings.userDetails,
      breadcrumb: const [AppStrings.userManagement, AppStrings.userDetails],
      userName: UserMockData.adminName,
      userRole: UserMockData.adminRole,
      userInitials: UserMockData.adminInitials,
      child: child,
    );
  }
}
