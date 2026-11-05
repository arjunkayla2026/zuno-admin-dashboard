import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_brand_logo.dart';

class LoginBrandHeader extends StatelessWidget {
  const LoginBrandHeader({super.key});

  static const double _logoSize = 52;
  static const double _logoIconSize = 26;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppBrandLogo(size: _logoSize, iconSize: _logoIconSize),
        const SizedBox(width: AppUtils.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: AppTextStyles.pageTitle.copyWith(color: AppColors.white),
              ),
              Text(
                AppStrings.adminPanel,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.sidebarTextUnselected,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
