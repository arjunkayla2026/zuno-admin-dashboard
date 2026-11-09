import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class SurgeLabelPill extends StatelessWidget {
  const SurgeLabelPill({super.key, required this.percent});

  static const double _iconSize = 11;
  static const double _iconGap = 4;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 7,
    vertical: 3,
  );

  final int percent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(AppUtils.spacingXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppImages.surgeChargeIcon,
            width: _iconSize,
            height: _iconSize,
            colorFilter: ColorFilter.mode(
              colors.onPrimarySoft,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: _iconGap),
          Flexible(
            child: Text(
              AppStrings.surgeUserLabel(percent),
              style: AppTextStyles.tableFootnote.copyWith(
                color: colors.onPrimarySoft,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
