import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class PasswordVisibilityToggle extends StatelessWidget {
  const PasswordVisibilityToggle({
    super.key,
    required this.obscured,
    required this.onPressed,
  });

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppUtils.spacingSm),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: context.appColors.textSecondary,
          textStyle: AppTextStyles.labelSmall,
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: AppUtils.spacingXs),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: IndexedStack(
          index: obscured ? 0 : 1,
          alignment: Alignment.center,
          children: const [Text(AppStrings.show), Text(AppStrings.hide)],
        ),
      ),
    );
  }
}
