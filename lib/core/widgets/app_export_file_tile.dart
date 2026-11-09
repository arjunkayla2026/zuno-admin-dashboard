import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';

class AppExportFileTile extends StatelessWidget {
  const AppExportFileTile({
    super.key,
    required this.fileName,
    required this.description,
  });

  static const double _iconTileSize = 30;
  static const double _iconSize = 16;
  static const double _iconGap = 10;
  static const double _badgeGap = 12;
  static const double _descriptionGap = 2;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(12, 10, 12, 10);

  final String fileName;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: _iconTileSize,
            height: _iconTileSize,
            decoration: BoxDecoration(
              color: colors.activeBadge,
              borderRadius: AppUtils.radiusSmall,
            ),
            child: Icon(
              Icons.description_outlined,
              size: _iconSize,
              color: colors.activeText,
            ),
          ),
          const SizedBox(width: _iconGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: _descriptionGap),
                Text(
                  description,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: _badgeGap),
          const AppStatusBadge(
            label: AppStrings.ready,
            status: AppStatus.active,
          ),
        ],
      ),
    );
  }
}
