import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_switch.dart';

class MaintenanceModeCard extends StatelessWidget {
  const MaintenanceModeCard({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  static const double _iconTileSize = 44;
  static const double _iconSize = 22;
  static const double _iconGap = 16;
  static const double _switchGap = 16;
  static const double _subtitleGap = 2;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(18, 16, 18, 18);

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textColor = context.colorScheme.onSurface;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: enabled ? colors.pendingBadge : context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: enabled ? AppColors.pendingBorder : AppColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: _iconTileSize,
            height: _iconTileSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: enabled
                  ? context.colorScheme.surface
                  : AppColors.statTileBackground,
              borderRadius: AppUtils.radiusSmall,
            ),
            child: SvgPicture.asset(
              AppImages.maintenanceModeIcon,
              width: _iconSize,
              height: _iconSize,
              colorFilter: ColorFilter.mode(
                enabled ? colors.pendingText : AppColors.segmentText,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: _iconGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.maintenanceMode,
                  style: AppTextStyles.titleMedium.copyWith(color: textColor),
                ),
                const SizedBox(height: _subtitleGap),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: AppStrings.maintenanceModeIs),
                      TextSpan(
                        text: enabled
                            ? AppStrings.maintenanceOn
                            : AppStrings.maintenanceOff,
                        style: const TextStyle(
                          color: AppColors.textLabel,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: enabled
                            ? AppStrings.maintenanceUnavailableTail
                            : AppStrings.maintenanceAvailableTail,
                      ),
                    ],
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: _switchGap),
          AppStatusSwitch(
            value: enabled,
            onChanged: onChanged,
            activeTrackColor: colors.pendingText,
          ),
        ],
      ),
    );
  }
}
