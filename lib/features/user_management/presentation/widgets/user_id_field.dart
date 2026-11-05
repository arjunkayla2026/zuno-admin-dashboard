import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class UserIdField extends StatelessWidget {
  const UserIdField({super.key, required this.userId});

  static const double _labelGap = 5;
  static const double _helperGap = 5;
  static const double _height = 40;
  static const double _sidePadding = 11;

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.userId,
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
            userId,
            style: AppTextStyles.mono.copyWith(
              color: context.appColors.inactiveText,
            ),
          ),
        ),
        const SizedBox(height: _helperGap),
        Text(
          AppStrings.userIdCannotBeChanged,
          style: AppTextStyles.captionSmall.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
