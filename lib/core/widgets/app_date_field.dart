import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';

class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.date,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.width = 142,
    this.height = 40,
  });

  static const double _iconSize = 14;
  static const double _leftPadding = 14;
  static const double _rightPadding = 16;

  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final double width;
  final double height;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusField);
    final textColor = context.colorScheme.onSurface;

    return Material(
      color: context.colorScheme.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: () => _pickDate(context),
        borderRadius: radius,
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.only(
            left: _leftPadding,
            right: _rightPadding,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  DateFormatter.numeric(date),
                  style: AppTextStyles.labelMedium.copyWith(color: textColor),
                ),
              ),
              Icon(Icons.calendar_today, size: _iconSize, color: textColor),
            ],
          ),
        ),
      ),
    );
  }
}
