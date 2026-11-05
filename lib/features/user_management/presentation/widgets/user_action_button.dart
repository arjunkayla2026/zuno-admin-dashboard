import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_anchored_menu.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_management_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/widgets/user_action_flow.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/widgets/user_action_menu.dart';

class UserActionButton extends StatelessWidget {
  const UserActionButton({super.key, required this.user});

  static const double _iconSize = 15;
  static const double _leftInset = 17;
  static const double _hitPadding = 6;
  static const double _menuTopOffset = 15;

  final AdminUser user;

  Future<void> _openMenu(BuildContext context) async {
    final cubit = context.read<UserManagementCubit>();

    final action = await showAnchoredMenu<UserAction>(
      anchorContext: context,
      size: UserActionMenu.size,
      position: (anchor) => Offset(
        anchor.center.dx - UserActionMenu.size.width / 2,
        anchor.center.dy - _menuTopOffset,
      ),
      builder: (_) => const UserActionMenu(),
    );

    if (action == null || !context.mounted) return;

    await runUserAction(
      context: context,
      action: action,
      user: user,
      onUserChanged: cubit.replaceUser,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: _leftInset),
      child: Tooltip(
        message: AppStrings.takeAction,
        child: Builder(
          builder: (anchorContext) => InkResponse(
            onTap: () => _openMenu(anchorContext),
            child: Padding(
              padding: const EdgeInsets.all(_hitPadding),
              child: SvgPicture.asset(
                AppImages.takeActionIcon,
                width: _iconSize,
                height: _iconSize,
                colorFilter: const ColorFilter.mode(
                  AppColors.tableActionIcon,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
