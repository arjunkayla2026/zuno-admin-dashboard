import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class MaintenanceTopBarBadge extends StatelessWidget {
  const MaintenanceTopBarBadge({super.key});

  static const double _iconSize = 12;
  static const double _iconGap = 6;
  static const double _radius = 999;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 5,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: colors.pendingBadge,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppImages.maintenanceModeIcon,
            width: _iconSize,
            height: _iconSize,
            colorFilter: ColorFilter.mode(colors.pendingText, BlendMode.srcIn),
          ),
          const SizedBox(width: _iconGap),
          Flexible(
            child: Text(
              AppStrings.maintenanceModeIsOn,
              style: AppTextStyles.tableFootnote.copyWith(
                color: colors.pendingText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
