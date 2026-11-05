import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';

class AdminSidebarTile extends StatelessWidget {
  const AdminSidebarTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  static const double _height = 42;
  static const double _sidePadding = 13;
  static const double _iconSize = 19;
  static const double _iconGap = 11;

  final AdminNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.sidebarIconSelected
        : AppColors.sidebarIconUnselected;
    final radius = BorderRadius.circular(AppTheme.radiusNavItem);

    return Material(
      color: selected ? AppColors.primary : AppColors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          constraints: const BoxConstraints(minHeight: _height),
          padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
          child: Row(
            children: [
              SvgPicture.asset(
                item.svgAsset,
                width: _iconSize,
                height: _iconSize,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(width: _iconGap),
              Expanded(
                child: Text(
                  item.label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
