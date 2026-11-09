import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dashed_border.dart';

class BannerDropTarget extends StatelessWidget {
  const BannerDropTarget({
    super.key,
    required this.height,
    required this.iconAsset,
    required this.tileColor,
    required this.iconColor,
    required this.title,
    required this.helper,
    required this.helperColor,
    required this.onTap,
  });

  static const double _tileSize = 46;
  static const double _iconSize = 20;
  static const double _tileGap = 12;
  static const double _helperGap = 8;

  final double height;
  final String iconAsset;
  final Color tileColor;
  final Color iconColor;
  final String title;
  final String helper;
  final Color helperColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusCard);

    return AppDashedBorder(
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(AppUtils.spacingLg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: _tileSize,
                    height: _tileSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: AppUtils.radiusSmall,
                    ),
                    child: SvgPicture.asset(
                      iconAsset,
                      width: _iconSize,
                      height: _iconSize,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  ),
                  const SizedBox(height: _tileGap),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.fieldValue.copyWith(
                      color: context.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: _helperGap),
                  Text(
                    helper,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.tableFootnote.copyWith(
                      color: helperColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
