import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_call_filter_bar.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_footer.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/call_history_cubit.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/call_history_state.dart';

class CallHistoryPanel extends StatelessWidget {
  const CallHistoryPanel({super.key, required this.tableBuilder});

  static const double _emptyHeight = 160;

  final Widget Function(List<CallLog> calls) tableBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallHistoryCubit, CallHistoryState>(
      builder: (context, state) {
        final cubit = context.read<CallHistoryCubit>();
        final isLoaded = state.status == LoadStatus.loaded;
        final calls = isLoaded ? state.calls : const <CallLog>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCallFilterBar(
              typeFilter: state.typeFilter,
              onTypeChanged: cubit.selectType,
              dateMode: state.dateMode,
              onDateModeChanged: cubit.selectDateMode,
              singleDate: state.singleDate,
              onSingleDateChanged: cubit.setSingleDate,
              rangeStart: state.rangeStart,
              onRangeStartChanged: cubit.setRangeStart,
              rangeEnd: state.rangeEnd,
              onRangeEndChanged: cubit.setRangeEnd,
              callCount: state.matchCount,
            ),
            tableBuilder(calls),
            if (state.status == LoadStatus.loading)
              const AppTableLoadingState()
            else if (state.status == LoadStatus.failure)
              AppTableErrorState(
                message: state.errorMessage ?? AppStrings.recordsLoadFailed,
                onRetry: cubit.load,
              )
            else if (calls.isEmpty)
              SizedBox(
                height: _emptyHeight,
                child: Center(
                  child: Text(
                    AppStrings.noCallsFound,
                    style: AppTextStyles.tableCell.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              AppTableFooter(
                firstIndex: state.firstIndex,
                shownCount: calls.length,
                totalCount: state.matchCount,
                currentPage: state.page,
                totalPages: state.totalPages,
                onPageChanged: cubit.goToPage,
              ),
          ],
        );
      },
    );
  }
}
