import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_anchored_menu.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_management_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_management_state.dart';

class UserFilterDropdown extends StatelessWidget {
  const UserFilterDropdown({super.key});

  static const double _minWidth = 115;
  static const double _leftPadding = 20;
  static const double _height = 42;
  static const double _chevronSize = 18;
  static const double _labelGap = 10;
  static const double _menuItemHeight = 42;
  static const double _menuPadding = 8;
  static const double _menuWidth = 170;
  static const Offset _menuOffset = Offset(8, 16);

  static String _label(UserFilter filter) => switch (filter) {
    UserFilter.all => AppStrings.allUsers,
    UserFilter.newUsers => AppStrings.newUsers,
    UserFilter.blocked => AppStrings.blockedUsers,
    UserFilter.deletedByAdmin => AppStrings.deletedByAdminFilter,
    UserFilter.deletedByUser => AppStrings.deletedByUserFilter,
  };

  Future<void> _openMenu(BuildContext context) async {
    final cubit = context.read<UserManagementCubit>();
    final height =
        _menuItemHeight * UserFilter.values.length + _menuPadding * 2;

    final selected = await showAnchoredMenu<UserFilter>(
      anchorContext: context,
      size: Size(_menuWidth, height),
      position: (anchor) => Offset(
        anchor.right + _menuOffset.dx - _menuWidth,
        anchor.bottom + _menuOffset.dy,
      ),
      builder: (menuContext) => Padding(
        padding: const EdgeInsets.symmetric(vertical: _menuPadding),
        child: Column(
          children: [
            for (final filter in UserFilter.values)
              InkWell(
                onTap: () => Navigator.of(menuContext).pop(filter),
                child: Container(
                  height: _menuItemHeight,
                  alignment: Alignment.center,
                  child: Text(
                    _label(filter),
                    style: AppTextStyles.menuItem.copyWith(
                      color: AppColors.menuText,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    if (selected != null) cubit.selectFilter(selected);
  }

  @override
  Widget build(BuildContext context) {
    final filter = context.select(
      (UserManagementCubit cubit) => cubit.state.filter,
    );

    return Material(
      color: AppColors.surface,
      borderRadius: AppUtils.radiusSmall,
      child: InkWell(
        onTap: () => _openMenu(context),
        borderRadius: AppUtils.radiusSmall,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: _minWidth,
            minHeight: _height,
          ),
          padding: const EdgeInsets.only(
            left: _leftPadding,
            right: AppUtils.spacingLg,
          ),
          decoration: BoxDecoration(
            borderRadius: AppUtils.radiusSmall,
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _label(filter),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.menuText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: _labelGap),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: _chevronSize,
                color: AppColors.textLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
