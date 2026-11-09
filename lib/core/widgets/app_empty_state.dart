import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  static const double _tileSize = 44;
  static const double _iconSize = 22;
  static const double _iconGap = 16;
  static const double _titleGap = 6;
  static const double _maxTextWidth = 440;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppUtils.spacingLg,
    vertical: 56,
  );

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxTextWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _tileSize,
                height: _tileSize,
                decoration: BoxDecoration(
                  color: AppColors.iconTileBackground,
                  borderRadius: AppUtils.radiusSmall,
                ),
                child: Icon(
                  icon,
                  size: _iconSize,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: _iconGap),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelLarge.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: _titleGap),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
