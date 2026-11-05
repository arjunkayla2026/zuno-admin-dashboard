import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
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
  static const double _iconSize = 16;
  static const double _editIconWidth = 14;
  static const double _editIconHeight = 13;
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
            icon: SvgPicture.asset(
              AppImages.editIcon,
              width: _editIconWidth,
              height: _editIconHeight,
              colorFilter: const ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
            label: AppStrings.edit,
            style: AppTextStyles.menuItem.copyWith(color: AppColors.menuText),
            gap: _editIconGap,
          ),
          _ActionItem(
            action: UserAction.block,
            icon: const Icon(
              Icons.block_flipped,
              size: _iconSize,
              color: AppColors.errorText,
            ),
            label: AppStrings.block,
            style: dangerStyle,
            gap: _iconGap,
          ),
          _ActionItem(
            action: UserAction.delete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: _iconSize,
              color: AppColors.errorText,
            ),
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
    required this.label,
    required this.style,
    required this.gap,
  });

  final UserAction action;
  final Widget icon;
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
            SizedBox(
              width: UserActionMenu._iconSize,
              child: Center(child: icon),
            ),
            SizedBox(width: gap),
            Text(label, style: style),
          ],
        ),
      ),
    );
  }
}
