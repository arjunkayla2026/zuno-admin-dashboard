import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_shell.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_empty_state.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/mock/user_mock_data.dart';

class HostDetailsShell extends StatelessWidget {
  const HostDetailsShell({super.key, required this.child});

  HostDetailsShell.message({super.key, required String message})
    : child = AppEmptyState(
        icon: Icons.person_outline_rounded,
        title: AppStrings.hostDetails,
        message: message,
      );

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      selectedItem: AdminNavItem.hostManagement,
      selectedSubItem: AdminSubNavItem.hostList,
      title: AppStrings.hostDetails,
      breadcrumb: const [AppStrings.hostManagement, AppStrings.hostDetails],
      userName: UserMockData.adminName,
      userRole: UserMockData.adminRole,
      userInitials: UserMockData.adminInitials,
      child: child,
    );
  }
}
