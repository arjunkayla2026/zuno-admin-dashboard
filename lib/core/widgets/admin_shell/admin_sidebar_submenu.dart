import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';

class AdminSidebarSubmenu extends StatelessWidget {
  const AdminSidebarSubmenu({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
  });

  static const double _lineInset = 22;
  static const double _topGap = 4;
  static const double _itemGap = 2;
  static const double _itemHeight = 34;
  static const double _itemPadding = 14;

  final List<AdminSubNavItem> items;
  final AdminSubNavItem? selectedItem;
  final ValueChanged<AdminSubNavItem> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: _lineInset, top: _topGap),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.sidebarDivider)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (index, item) in items.indexed) ...[
              if (index > 0) const SizedBox(height: _itemGap),
              _SubmenuTile(
                item: item,
                selected: item == selectedItem,
                onTap: () => onItemSelected(item),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubmenuTile extends StatelessWidget {
  const _SubmenuTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AdminSubNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppUtils.radiusSmall,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AdminSidebarSubmenu._itemHeight,
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(
            horizontal: AdminSidebarSubmenu._itemPadding,
            vertical: AppUtils.spacingXs,
          ),
          decoration: selected ? AppUtils.selectedSubmoduleDecoration() : null,
          child: Text(
            item.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: selected
                  ? AppColors.submoduleSelectedText
                  : AppColors.sidebarTextUnselected,
              fontWeight: selected ? FontWeight.w600 : null,
            ),
          ),
        ),
      ),
    );
  }
}
