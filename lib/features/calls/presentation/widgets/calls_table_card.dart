import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_footer.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/calls_cubit.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/calls_state.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/widgets/calls_table.dart';

class CallsTableCard extends StatelessWidget {
  const CallsTableCard({super.key});

  static const double _emptyHeight = 160;
  static const double _hintIconSize = 14;
  static const EdgeInsets _hintPadding = EdgeInsets.fromLTRB(12, 9, 12, 9);

  @override
  Widget build(BuildContext context) {
    final muted = context.appColors.textSecondary;

    return BlocBuilder<CallsCubit, CallsState>(
      builder: (context, state) {
        final isLoaded = state.status == LoadStatus.loaded;
        final calls = isLoaded ? state.calls : const <CallLog>[];

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
              Padding(
                padding: _hintPadding,
                child: Row(
                  children: [
                    Icon(
                      Icons.chevron_right_rounded,
                      size: _hintIconSize,
                      color: muted,
                    ),
                    const SizedBox(width: AppUtils.spacingXs),
                    Expanded(
                      child: Text(
                        AppStrings.scrollSidewaysForFields(
                          CallsTable.columnCount,
                        ),
                        style: AppTextStyles.tableFootnote.copyWith(
                          color: muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CallsTable(
                calls: calls,
                firstNumber: state.firstIndex + 1,
                onCallTap: (call) =>
                    Navigator.of(context)
                        .pushNamed(AppRoutes.callDetails, arguments: call),
              ),
              if (state.status == LoadStatus.loading)
                const AppTableLoadingState()
              else if (state.status == LoadStatus.failure)
                AppTableErrorState(
                  message: state.errorMessage ?? AppStrings.recordsLoadFailed,
                  onRetry: context.read<CallsCubit>().loadCalls,
                )
              else if (calls.isEmpty)
                SizedBox(
                  height: _emptyHeight,
                  child: Center(
                    child: Text(
                      AppStrings.noCallsFound,
                      style: AppTextStyles.tableCell.copyWith(color: muted),
                    ),
                  ),
                )
              else
                AppTableFooter(
                  firstIndex: state.firstIndex,
                  shownCount: calls.length,
                  totalCount: state.shownCount,
                  currentPage: state.page,
                  totalPages: state.totalPages,
                  onPageChanged: context.read<CallsCubit>().goToPage,
                ),
            ],
          ),
        );
      },
    );
  }
}
