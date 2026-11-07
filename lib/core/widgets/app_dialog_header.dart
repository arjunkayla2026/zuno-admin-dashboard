import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class AppDialogHeader extends StatelessWidget {
  const AppDialogHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  static const double tileSize = 46;
  static const double iconSize = 22;
  static const double _gap = 14;

  final Widget icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: tileSize,
          height: tileSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.iconTileBackground,
            borderRadius: AppUtils.radiusSmall,
          ),
          child: icon,
        ),
        const SizedBox(width: _gap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              if (subtitle case final subtitle?)
                Text(
                  subtitle,
                  style: AppTextStyles.tableFootnote.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
