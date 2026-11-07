import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_shell.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_state.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/maintenance_top_bar_badge.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/settings_content.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/mock/user_mock_data.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static AdminSubNavItem _subItem(SettingsTab tab) => switch (tab) {
    SettingsTab.maintenanceMode => AdminSubNavItem.maintenanceMode,
    SettingsTab.adminManagement => AdminSubNavItem.adminManagement,
    SettingsTab.notificationManagement =>
      AdminSubNavItem.notificationManagement,
    SettingsTab.bannerImageManagement => AdminSubNavItem.bannerImageManagement,
  };

  static SettingsTab? _tabFor(AdminSubNavItem item) => switch (item) {
    AdminSubNavItem.maintenanceMode => SettingsTab.maintenanceMode,
    AdminSubNavItem.adminManagement => SettingsTab.adminManagement,
    AdminSubNavItem.notificationManagement =>
      SettingsTab.notificationManagement,
    AdminSubNavItem.bannerImageManagement => SettingsTab.bannerImageManagement,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: BlocProvider(
        create: (_) => SettingsCubit(),
        child: BlocSelector<SettingsCubit, SettingsState, (SettingsTab, bool)>(
          selector: (state) => (state.tab, state.maintenanceEnabled),
          builder: (context, selection) => AdminShell(
            selectedItem: AdminNavItem.settings,
            selectedSubItem: _subItem(selection.$1),
            topBarNotice: selection.$2 ? const MaintenanceTopBarBadge() : null,
            onSubItemSelected: (item) {
              final selected = _tabFor(item);
              if (selected != null) {
                context.read<SettingsCubit>().selectTab(selected);
              }
            },
            title: AppStrings.settings,
            userName: UserMockData.adminName,
            userRole: UserMockData.adminRole,
            userInitials: UserMockData.adminInitials,
            child: const SettingsContent(),
          ),
        ),
      ),
    );
  }
}
