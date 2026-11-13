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
import 'package:zuno_admin_dashboard/features/reports/data/models/user_report.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/state/reports_cubit.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/state/reports_state.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/widgets/reports_table.dart';

class ReportsTableCard extends StatelessWidget {
  const ReportsTableCard({super.key});

  static const double _emptyHeight = 160;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        final cubit = context.read<ReportsCubit>();
        final reports = state.status == LoadStatus.loaded
            ? state.reports
            : const <UserReport>[];

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
              ReportsTable(reports: reports),
              if (state.status == LoadStatus.loading)
                const AppTableLoadingState()
              else if (state.status == LoadStatus.failure)
                AppTableErrorState(
                  message: state.errorMessage ?? AppStrings.recordsLoadFailed,
                  onRetry: cubit.loadReports,
                )
              else if (reports.isEmpty)
                SizedBox(
                  height: _emptyHeight,
                  child: Center(
                    child: Text(
                      AppStrings.noReportsFound,
                      style: AppTextStyles.tableCell.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                AppTableFooter(
                  firstIndex: state.firstIndex,
                  shownCount: reports.length,
                  totalCount: state.totalCount,
                  currentPage: state.page,
                  totalPages: state.totalPages,
                  onPageChanged: cubit.goToPage,
                ),
            ],
          ),
        );
      },
    );
  }
}
