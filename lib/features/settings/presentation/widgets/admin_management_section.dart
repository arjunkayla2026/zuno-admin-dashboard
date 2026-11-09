import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_empty_state.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/admin_session_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_state.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/admin_flow.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/admins_table.dart';

class AdminManagementSection extends StatelessWidget {
  const AdminManagementSection({super.key});

  static const EdgeInsets _toolbarPadding = EdgeInsets.fromLTRB(16, 11, 16, 11);

  Widget _body(BuildContext context, SettingsState state, bool canManage) {
    return switch (state.adminsStatus) {
      LoadStatus.loading => const AppTableLoadingState(),
      LoadStatus.failure => AppTableErrorState(
        message: state.adminsError ?? AppStrings.recordsLoadFailed,
        onRetry: context.read<SettingsCubit>().loadAdmins,
      ),
      LoadStatus.loaded when state.admins.isEmpty => const AppEmptyState(
        icon: Icons.admin_panel_settings_outlined,
        title: AppStrings.noAdminsTitle,
        message: AppStrings.noAdminsMessage,
      ),
      LoadStatus.loaded => AdminsTable(
        admins: state.admins,
        canManage: canManage,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final canManage = context.select<AdminSessionCubit, bool>(
      (cubit) => cubit.state.account?.canManageAdmins ?? false,
    );
    final muted = AppTextStyles.bodySmall.copyWith(
      color: context.appColors.textSecondary,
    );

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.admins != current.admins ||
          previous.adminsStatus != current.adminsStatus ||
          previous.adminsError != current.adminsError,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: _toolbarPadding,
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppUtils.spacingSm,
                  runSpacing: AppUtils.spacingSm,
                  children: [
                    Text(
                      AppStrings.adminsCount(state.admins.length),
                      style: muted,
                    ),
                    if (canManage)
                      AppPrimaryButton(
                        label: AppStrings.addAdmin,
                        icon: Icons.add_rounded,
                        compact: true,
                        onPressed: () => openAdminSheet(context),
                      )
                    else
                      Text(AppStrings.superAdminsManageAdmins, style: muted),
                  ],
                ),
              ),
            ),
            const Divider(color: AppColors.cardBorder),
            _body(context, state, canManage),
          ],
        );
      },
    );
  }
}
