import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_sidebar_submenu.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_sidebar_tile.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_brand_logo.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.selectedItem,
    required this.userName,
    required this.userRole,
    this.items = AdminNavItem.values,
    this.selectedSubItem,
    this.onItemSelected,
    this.onSubItemSelected,
  });

  static const double width = 264;
  static const double _logoSize = 42;
  static const double _logoIconSize = 22;
  static const double _tileGap = 3;
  static const double _horizontalInset = 16;
  static const double _brandInset = 26;
  static const double _brandTop = 23;
  static const double _brandBottom = 24;

  final List<AdminNavItem> items;
  final AdminNavItem selectedItem;
  final String userName;
  final String userRole;
  final AdminSubNavItem? selectedSubItem;
  final ValueChanged<AdminNavItem>? onItemSelected;
  final ValueChanged<AdminSubNavItem>? onSubItemSelected;

  @override
  Widget build(BuildContext context) {
    final caption = AppTextStyles.captionSmall.copyWith(
      color: AppColors.sidebarTextUnselected,
    );

    return Container(
      width: width,
      color: AppColors.sidebarBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _brandInset,
                _brandTop,
                _brandInset,
                _brandBottom,
              ),
              child: Row(
                children: [
                  const AppBrandLogo(size: _logoSize, iconSize: _logoIconSize),
                  const SizedBox(width: AppUtils.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.appName,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        Text(AppStrings.adminPanel, style: caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalInset,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: _tileGap),
                itemBuilder: (_, index) {
                  final item = items[index];
                  final selected = item == selectedItem;
                  final tile = AdminSidebarTile(
                    item: item,
                    selected: selected,
                    onTap: () => onItemSelected?.call(item),
                  );
                  if (!selected || item.subItems.isEmpty) return tile;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      tile,
                      AdminSidebarSubmenu(
                        items: item.subItems,
                        selectedItem: selectedSubItem,
                        onItemSelected: (subItem) =>
                            onSubItemSelected?.call(subItem),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: _horizontalInset),
              child: Divider(color: AppColors.sidebarDivider),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _brandInset,
                vertical: AppUtils.spacingLg,
              ),
              child: Text(
                '${AppStrings.signedInAs} $userName\n$userRole',
                style: caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
