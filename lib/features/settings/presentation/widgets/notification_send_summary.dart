import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class NotificationSendSummary extends StatelessWidget {
  const NotificationSendSummary({
    super.key,
    required this.audience,
    required this.languages,
    required this.title,
  });

  static const int _labelFlex = 2;
  static const int _valueFlex = 3;
  static const double _rowGap = 10;
  static const double _labelGap = 12;
  static const EdgeInsets _padding = EdgeInsets.all(AppUtils.spacingLg);

  final String audience;
  final String languages;
  final String title;

  Widget _row(String label, String value, TextStyle labelStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: _labelFlex,
          child: Text(label, style: labelStyle),
        ),
        const SizedBox(width: _labelGap),
        Flexible(
          flex: _valueFlex,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.tableCell.copyWith(
              color: AppColors.segmentText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = AppTextStyles.tableCell.copyWith(
      color: context.appColors.textSecondary,
    );
    final rows = [
      _row(AppStrings.sendTo, audience, label),
      if (languages.isNotEmpty)
        _row(AppStrings.hostMotherTongue, languages, label),
      _row(AppStrings.notificationTitle, title, label),
    ];

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: AppColors.statTileBackground,
        borderRadius: AppUtils.radiusSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, row) in rows.indexed) ...[
            if (index > 0) const SizedBox(height: _rowGap),
            row,
          ],
        ],
      ),
    );
  }
}
