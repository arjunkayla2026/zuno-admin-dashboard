import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class AppReadOnlyField extends StatelessWidget {
  const AppReadOnlyField({super.key, required this.label, required this.value});

  static const double _labelGap = 5;
  static const double _height = 40;
  static const double _sidePadding = 11;

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: _labelGap),
        Container(
          height: _height,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
          decoration: BoxDecoration(
            color: AppColors.statTileBackground,
            borderRadius: BorderRadius.circular(AppTheme.radiusField),
          ),
          child: Text(
            value,
            style: AppTextStyles.mono.copyWith(
              color: context.appColors.inactiveText,
            ),
          ),
        ),
      ],
    );
  }
}
