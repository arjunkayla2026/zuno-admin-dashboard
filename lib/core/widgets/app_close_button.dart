import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class AppCloseButton extends StatelessWidget {
  const AppCloseButton({
    super.key,
    required this.onPressed,
    this.size = 36,
    this.iconSize = 18,
  });

  final VoidCallback onPressed;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusField);

    return Tooltip(
      message: AppStrings.close,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Icon(
            Icons.close_rounded,
            size: iconSize,
            color: context.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
