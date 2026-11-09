import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/call_filter.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_date_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_segmented_control.dart';

class AppCallFilterBar extends StatelessWidget {
  const AppCallFilterBar({
    super.key,
    required this.typeFilter,
    required this.onTypeChanged,
    required this.dateMode,
    required this.onDateModeChanged,
    required this.singleDate,
    required this.onSingleDateChanged,
    required this.rangeStart,
    required this.onRangeStartChanged,
    required this.rangeEnd,
    required this.onRangeEndChanged,
    required this.callCount,
  });

  static const double _dateWidth = 150;
  static const double _controlGap = 12;
  static const double _dateHeight = 38;
  static const double _hintIconSize = 14;
  static const double _hintCountGap = 20;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(20, 15, 20, 15);

  final CallTypeFilter typeFilter;
  final ValueChanged<CallTypeFilter> onTypeChanged;
  final CallDateMode dateMode;
  final ValueChanged<CallDateMode> onDateModeChanged;
  final DateTime singleDate;
  final ValueChanged<DateTime> onSingleDateChanged;
  final DateTime rangeStart;
  final ValueChanged<DateTime> onRangeStartChanged;
  final DateTime rangeEnd;
  final ValueChanged<DateTime> onRangeEndChanged;
  final int callCount;

  @override
  Widget build(BuildContext context) {
    final muted = context.appColors.textSecondary;
    final footnote = AppTextStyles.tableFootnote.copyWith(color: muted);

    return Padding(
      padding: _padding,
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
                value: typeFilter,
                onChanged: onTypeChanged,
              ),
              AppSegmentedControl<CallDateMode>(
                options: const {
                  CallDateMode.single: AppStrings.singleDate,
                  CallDateMode.range: AppStrings.dateRange,
                },
                value: dateMode,
                onChanged: onDateModeChanged,
              ),
              if (dateMode == CallDateMode.single)
                AppDateField(
                  date: singleDate,
                  width: _dateWidth,
                  height: _dateHeight,
                  onChanged: onSingleDateChanged,
                )
              else
                Wrap(
                  spacing: AppUtils.spacingSm,
                  runSpacing: AppUtils.spacingSm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppDateField(
                      date: rangeStart,
                      lastDate: rangeEnd,
                      width: _dateWidth,
                      height: _dateHeight,
                      onChanged: onRangeStartChanged,
                    ),
                    Text(
                      AppStrings.dateRangeSeparator,
                      style: AppTextStyles.bodySmall.copyWith(color: muted),
                    ),
                    AppDateField(
                      date: rangeEnd,
                      firstDate: rangeStart,
                      width: _dateWidth,
                      height: _dateHeight,
                      onChanged: onRangeEndChanged,
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
              Text(AppStrings.callsCount(callCount), style: footnote),
            ],
          ),
        ],
      ),
    );
  }
}
