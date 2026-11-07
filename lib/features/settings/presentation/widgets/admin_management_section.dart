import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/admin_account.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_state.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/admin_flow.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/admins_table.dart';

class AdminManagementSection extends StatelessWidget {
  const AdminManagementSection({super.key});

  static const EdgeInsets _toolbarPadding = EdgeInsets.fromLTRB(16, 11, 16, 11);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SettingsCubit, SettingsState, List<AdminAccount>>(
      selector: (state) => state.admins,
      builder: (context, admins) {
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
                  runSpacing: AppUtils.spacingSm,
                  children: [
                    Text(
                      AppStrings.adminsCount(admins.length),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                    AppPrimaryButton(
                      label: AppStrings.addAdmin,
                      icon: Icons.add_rounded,
                      compact: true,
                      onPressed: () => openAdminSheet(context),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: AppColors.cardBorder),
            AdminsTable(admins: admins),
          ],
        );
      },
    );
  }
}
