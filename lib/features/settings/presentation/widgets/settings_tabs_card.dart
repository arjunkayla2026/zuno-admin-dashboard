import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_underline_tabs.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_state.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/admin_management_section.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/banner_management_section.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/maintenance_mode_section.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/notification_composer_section.dart';

class SettingsTabsCard extends StatelessWidget {
  const SettingsTabsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SettingsCubit, SettingsState, SettingsTab>(
      selector: (state) => state.tab,
      builder: (context, tab) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppUnderlineTabs<SettingsTab>(
                tabs: const {
                  SettingsTab.maintenanceMode: AppStrings.maintenanceMode,
                  SettingsTab.adminManagement: AppStrings.adminManagement,
                  SettingsTab.notificationManagement:
                      AppStrings.notificationManagement,
                  SettingsTab.bannerImageManagement:
                      AppStrings.bannerImageManagement,
                },
                value: tab,
                onChanged: context.read<SettingsCubit>().selectTab,
              ),
              const Divider(color: AppColors.cardBorder),
              switch (tab) {
                SettingsTab.maintenanceMode => const MaintenanceModeSection(),
                SettingsTab.adminManagement => const AdminManagementSection(),
                SettingsTab.notificationManagement =>
                  const NotificationComposerSection(),
                SettingsTab.bannerImageManagement =>
                  const BannerManagementSection(),
              },
            ],
          ),
        );
      },
    );
  }
}
