import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_footer.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_management_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_management_state.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/host_table.dart';

class HostTableCard extends StatelessWidget {
  const HostTableCard({super.key});

  static const double _emptyHeight = 160;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostManagementCubit, HostManagementState>(
      builder: (context, state) {
        final hosts = state.pageHosts;

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
              HostTable(hosts: hosts),
              if (state.status == LoadStatus.loading)
                const AppTableLoadingState()
              else if (state.status == LoadStatus.failure)
                AppTableErrorState(
                  message: state.errorMessage ?? AppStrings.recordsLoadFailed,
                  onRetry: context.read<HostManagementCubit>().loadHosts,
                )
              else if (hosts.isEmpty)
                SizedBox(
                  height: _emptyHeight,
                  child: Center(
                    child: Text(
                      AppStrings.noHostsFound,
                      style: AppTextStyles.tableCell.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                AppTableFooter(
                  firstIndex: state.firstIndex,
                  shownCount: hosts.length,
                  totalCount: state.filteredHosts.length,
                  currentPage: state.page,
                  totalPages: state.totalPages,
                  onPageChanged: context.read<HostManagementCubit>().goToPage,
                ),
            ],
          ),
        );
      },
    );
  }
}
