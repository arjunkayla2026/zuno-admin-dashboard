import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_date_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_segmented_control.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_state.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/call_history_table.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/history_footer.dart';

class CallHistoryTab extends StatelessWidget {
  const CallHistoryTab({super.key});

  static const double _dateWidth = 150;
  static const double _controlGap = 12;
  static const double _dateHeight = 38;
  static const double _hintIconSize = 14;
  static const double _hintCountGap = 20;
  static const EdgeInsets _toolbarPadding = EdgeInsets.fromLTRB(20, 15, 20, 15);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
      builder: (context, state) {
        final cubit = context.read<UserDetailsCubit>();
        final muted = context.appColors.textSecondary;
        final calls = state.filteredCalls;
        final footnote = AppTextStyles.tableFootnote.copyWith(color: muted);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: _toolbarPadding,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppUtils.spacingMd,
                runSpacing: AppUtils.spacingSm,
                children: [
                  Wrap(
                    spacing: _controlGap,
                    runSpacing: AppUtils.spacingSm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppSegmentedControl<CallTypeFilter>(
                        options: const {
                          CallTypeFilter.all: AppStrings.all,
                          CallTypeFilter.audio: AppStrings.audio,
                          CallTypeFilter.video: AppStrings.video,
                        },
                        value: state.typeFilter,
                        onChanged: cubit.selectType,
                      ),
                      AppSegmentedControl<CallDateMode>(
                        options: const {
                          CallDateMode.single: AppStrings.singleDate,
                          CallDateMode.range: AppStrings.dateRange,
                        },
                        value: state.dateMode,
                        onChanged: cubit.selectDateMode,
                      ),
                      if (state.dateMode == CallDateMode.single)
                        AppDateField(
                          date: state.singleDate,
                          width: _dateWidth,
                          height: _dateHeight,
                          onChanged: cubit.setSingleDate,
                        )
                      else
                        Wrap(
                          spacing: AppUtils.spacingSm,
                          runSpacing: AppUtils.spacingSm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            AppDateField(
                              date: state.rangeStart,
                              lastDate: state.rangeEnd,
                              width: _dateWidth,
                              height: _dateHeight,
                              onChanged: cubit.setRangeStart,
                            ),
                            Text(
                              AppStrings.dateRangeSeparator,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: muted,
                              ),
                            ),
                            AppDateField(
                              date: state.rangeEnd,
                              firstDate: state.rangeStart,
                              width: _dateWidth,
                              height: _dateHeight,
                              onChanged: cubit.setRangeEnd,
                            ),
                          ],
                        ),
                    ],
                  ),
                  Wrap(
                    spacing: _hintCountGap,
                    runSpacing: AppUtils.spacingXs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Wrap(
                        spacing: AppUtils.spacingXs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            Icons.chevron_right_rounded,
                            size: _hintIconSize,
                            color: muted,
                          ),
                          Text(AppStrings.scrollSidewaysHint, style: footnote),
                        ],
                      ),
                      Text(
                        AppStrings.callsCount(calls.length),
                        style: footnote,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CallHistoryTable(calls: calls),
            HistoryFooter(shown: calls.length, total: state.calls.length),
          ],
        );
      },
    );
  }
}
