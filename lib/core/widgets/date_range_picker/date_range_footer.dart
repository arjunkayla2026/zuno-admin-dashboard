import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';

class DateRangeFooter extends StatelessWidget {
  const DateRangeFooter({
    super.key,
    required this.start,
    required this.end,
    required this.onCancel,
    required this.onApply,
  });

  static const int _hoursPerDay = 24;

  final DateTime? start;
  final DateTime? end;
  final VoidCallback onCancel;
  final VoidCallback? onApply;

  String get _summary {
    final start = this.start;
    final end = this.end;
    if (start == null) return AppStrings.selectStartDate;
    if (end == null) {
      return AppStrings.dateRangeLabel(
        DateFormatter.short(start),
        AppStrings.selectEndDate,
      );
    }
    final hours = end.difference(start).inHours;
    return AppStrings.dateRangeSummary(
      AppStrings.dateRangeLabel(
        DateFormatter.short(start),
        DateFormatter.short(end),
      ),
      (hours / _hoursPerDay).round() + 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: AppUtils.spacingSm,
      spacing: AppUtils.spacingLg,
      children: [
        Text(
          _summary,
          style: AppTextStyles.tableCell.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSecondaryButton(label: AppStrings.cancel, onPressed: onCancel),
            const SizedBox(width: AppUtils.spacingSm),
            AppPrimaryButton(
              label: AppStrings.apply,
              compact: true,
              onPressed: onApply,
            ),
          ],
        ),
      ],
    );
  }
}
