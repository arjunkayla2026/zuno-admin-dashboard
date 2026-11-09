import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';

enum AppMenuAction { edit, block, unblock, delete }

class AppActionMenu extends StatelessWidget {
  const AppActionMenu({super.key, this.actions = defaultActions});

  static const List<AppMenuAction> defaultActions = [
    AppMenuAction.edit,
    AppMenuAction.block,
    AppMenuAction.delete,
  ];
  static const List<AppMenuAction> _blockedAccountActions = [
    AppMenuAction.edit,
    AppMenuAction.unblock,
    AppMenuAction.delete,
  ];

  static const double _itemHeight = 42;
  static const double _padding = 11;
  static const double _width = 167;
  static const double _editIconGap = 22;
  static const double _iconGap = 13;
  static const double _iconSize = 16;
  static const double _editIconWidth = 14;
  static const double _editIconHeight = 13;

  final List<AppMenuAction> actions;

  static List<AppMenuAction> accountActions({required bool isBlocked}) =>
      isBlocked ? _blockedAccountActions : defaultActions;

  static Size sizeFor(List<AppMenuAction> actions) =>
      Size(_width, _itemHeight * actions.length + _padding * 2);

  Widget _item(AppMenuAction action) {
    final dangerStyle = AppTextStyles.labelSmall.copyWith(
      color: AppColors.errorText,
    );

    return switch (action) {
      AppMenuAction.edit => _ActionItem(
        action: action,
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
      AppMenuAction.block => _ActionItem(
        action: action,
        icon: const Icon(
          Icons.block_flipped,
          size: _iconSize,
          color: AppColors.errorText,
        ),
        label: AppStrings.block,
        style: dangerStyle,
        gap: _iconGap,
      ),
      AppMenuAction.unblock => _ActionItem(
        action: action,
        icon: const Icon(
          Icons.lock_open_rounded,
          size: _iconSize,
          color: AppColors.textPrimary,
        ),
        label: AppStrings.unblock,
        style: AppTextStyles.menuItem.copyWith(color: AppColors.menuText),
        gap: _iconGap,
      ),
      AppMenuAction.delete => _ActionItem(
        action: action,
        icon: const Icon(
          Icons.delete_outline_rounded,
          size: _iconSize,
          color: AppColors.errorText,
        ),
        label: AppStrings.delete,
        style: dangerStyle,
        gap: _iconGap,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _padding),
      child: Column(children: [for (final action in actions) _item(action)]),
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

  final AppMenuAction action;
  final Widget icon;
  final String label;
  final TextStyle style;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(action),
      child: SizedBox(
        height: AppActionMenu._itemHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: AppActionMenu._iconSize,
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
