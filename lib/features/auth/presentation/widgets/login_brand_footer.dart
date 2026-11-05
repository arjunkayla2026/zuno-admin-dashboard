import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class LoginBrandFooter extends StatelessWidget {
  const LoginBrandFooter({super.key});

  static const double _itemGap = 28;

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: _itemGap,
      runSpacing: AppUtils.spacingSm,
      children: [
        _FooterItem(
          icon: Icons.lock_outline_rounded,
          label: AppStrings.secureAdminLogin,
        ),
        _FooterItem(
          icon: Icons.check_circle_outline_rounded,
          label: AppStrings.approvedAdminsOnly,
        ),
      ],
    );
  }
}

class _FooterItem extends StatelessWidget {
  const _FooterItem({required this.icon, required this.label});

  static const double _iconSize = 16;

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: _iconSize, color: AppColors.sidebarTextUnselected),
        const SizedBox(width: AppUtils.spacingSm),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.sidebarTextUnselected,
          ),
        ),
      ],
    );
  }
}
