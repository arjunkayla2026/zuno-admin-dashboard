import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';

enum UserAction { edit, block, delete }

class UserActionMenu extends StatelessWidget {
  const UserActionMenu({super.key});

  static const double _itemHeight = 42;
  static const double _padding = 11;
  static const double _editIconGap = 22;
  static const double _iconGap = 13;
  static const Size size = Size(167, _itemHeight * 3 + _padding * 2);

  @override
  Widget build(BuildContext context) {
    final dangerStyle = AppTextStyles.labelSmall.copyWith(
      color: AppColors.errorText,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _padding),
      child: Column(
        children: [
          _ActionItem(
            action: UserAction.edit,
            icon: Icons.border_color_outlined,
            iconColor: AppColors.textPrimary,
            label: AppStrings.edit,
            style: AppTextStyles.menuItem.copyWith(color: AppColors.menuText),
            gap: _editIconGap,
          ),
          _ActionItem(
            action: UserAction.block,
            icon: Icons.block_rounded,
            iconColor: AppColors.errorText,
            label: AppStrings.block,
            style: dangerStyle,
            gap: _iconGap,
          ),
          _ActionItem(
            action: UserAction.delete,
            icon: Icons.delete_outline_rounded,
            iconColor: AppColors.errorText,
            label: AppStrings.delete,
            style: dangerStyle,
            gap: _iconGap,
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.action,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.style,
    required this.gap,
  });

  static const double _iconSize = 16;

  final UserAction action;
  final IconData icon;
  final Color iconColor;
  final String label;
  final TextStyle style;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(action),
      child: SizedBox(
        height: UserActionMenu._itemHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: _iconSize, color: iconColor),
            SizedBox(width: gap),
            Text(label, style: style),
          ],
        ),
      ),
    );
  }
}
