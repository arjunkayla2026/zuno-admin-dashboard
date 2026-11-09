import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class MaintenanceModeNote extends StatelessWidget {
  const MaintenanceModeNote({super.key});

  static const double _iconSize = 13;
  static const double _iconGap = 8;
  static const double _iconTopInset = 3;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(12, 10, 14, 10);

  @override
  Widget build(BuildContext context) {
    final muted = context.appColors.textSecondary;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: AppColors.statTileBackground,
        borderRadius: AppUtils.radiusSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: _iconTopInset),
            child: Icon(
              Icons.info_outline_rounded,
              size: _iconSize,
              color: muted,
            ),
          ),
          const SizedBox(width: _iconGap),
          Expanded(
            child: Text(
              AppStrings.maintenanceNote,
              style: AppTextStyles.noteText.copyWith(
                color: AppColors.segmentText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
