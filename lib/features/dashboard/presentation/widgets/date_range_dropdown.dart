import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/state/dashboard_state.dart';

class DateRangeDropdown extends StatelessWidget {
  const DateRangeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const double _width = 230;
  static const double _height = 40;
  static const double _iconSize = 18;

  final DashboardRangeType value;
  final ValueChanged<DashboardRangeType> onChanged;

  static String _label(DashboardRangeType type) => switch (type) {
    DashboardRangeType.today => AppStrings.today,
    DashboardRangeType.custom => AppStrings.customDateRange,
  };

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final mutedColor = context.appColors.textSecondary;

    return PopupMenuButton<DashboardRangeType>(
      initialValue: value,
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints.tightFor(width: _width),
      itemBuilder: (_) => [
        for (final type in DashboardRangeType.values)
          PopupMenuItem(
            value: type,
            child: Text(_label(type), style: AppTextStyles.bodySmall),
          ),
      ],
      child: Container(
        width: _width,
        height: _height,
        padding: const EdgeInsets.symmetric(horizontal: AppUtils.spacingSm),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusField),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule_rounded, size: _iconSize, color: mutedColor),
            const SizedBox(width: AppUtils.spacingMd),
            Expanded(
              child: Text(
                _label(value),
                style: AppTextStyles.labelSmall.copyWith(color: textColor),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: _iconSize,
              color: mutedColor,
            ),
          ],
        ),
      ),
    );
  }
}
