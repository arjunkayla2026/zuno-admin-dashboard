import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';

class LoginBrandMessage extends StatelessWidget {
  const LoginBrandMessage({super.key});

  static const double _descriptionWidth = 460;
  static const double _headingGap = 18;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: AppTextStyles.splashHeading.copyWith(color: AppColors.white),
            children: const [
              TextSpan(text: AppStrings.loginHeadingLead),
              TextSpan(
                text: AppStrings.loginHeadingHighlight,
                style: TextStyle(color: AppColors.primary),
              ),
              TextSpan(text: AppStrings.loginHeadingTail),
            ],
          ),
        ),
        const SizedBox(height: _headingGap),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _descriptionWidth),
          child: Text(
            AppStrings.loginDescription,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.sidebarTextUnselected,
            ),
          ),
        ),
      ],
    );
  }
}
