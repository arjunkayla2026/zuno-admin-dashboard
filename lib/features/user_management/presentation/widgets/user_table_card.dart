import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_pagination.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_management_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_management_state.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/widgets/user_table.dart';

class UserTableCard extends StatelessWidget {
  const UserTableCard({super.key});

  static const double _footerHeight = 50;
  static const double _emptyHeight = 160;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserManagementCubit, UserManagementState>(
      builder: (context, state) {
        final users = state.pageUsers;
        final total = state.filteredUsers.length;

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
              UserTable(users: users),
              if (users.isEmpty)
                SizedBox(
                  height: _emptyHeight,
                  child: Center(
                    child: Text(
                      AppStrings.noUsersFound,
                      style: AppTextStyles.tableCell.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  constraints: const BoxConstraints(minHeight: _footerHeight),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppUtils.spacingLg,
                    vertical: AppUtils.spacingSm,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: AppUtils.spacingSm,
                    children: [
                      Text(
                        AppStrings.showingRange(
                          state.firstIndex + 1,
                          state.firstIndex + users.length,
                          total,
                        ),
                        style: AppTextStyles.tableFootnote.copyWith(
                          color: context.appColors.textSecondary,
                        ),
                      ),
                      AppPagination(
                        currentPage: state.page,
                        totalPages: state.totalPages,
                        onPageChanged: context
                            .read<UserManagementCubit>()
                            .goToPage,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
