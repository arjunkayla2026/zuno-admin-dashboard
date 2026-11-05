import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class RechargeDialogHeader extends StatelessWidget {
  const RechargeDialogHeader({super.key, required this.title, this.subtitle});

  static const double _tileSize = 46;
  static const double _iconSize = 22;
  static const double _gap = 14;

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: _tileSize,
          height: _tileSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.iconTileBackground,
            borderRadius: AppUtils.radiusSmall,
          ),
          child: SvgPicture.asset(
            AppImages.rechargeIcon,
            width: _iconSize,
            height: _iconSize,
            colorFilter: const ColorFilter.mode(
              AppColors.primaryDark,
              BlendMode.srcIn,
            ),
          ),
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
