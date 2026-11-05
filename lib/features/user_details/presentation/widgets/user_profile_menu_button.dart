import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_anchored_menu.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/widgets/user_action_flow.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/widgets/user_action_menu.dart';

class UserProfileMenuButton extends StatelessWidget {
  const UserProfileMenuButton({super.key});

  static const double _iconSize = 24;
  static const double _menuRightOffset = 6;
  static const double _menuTopOffset = 39;

  Future<void> _openMenu(BuildContext context) async {
    final cubit = context.read<UserDetailsCubit>();

    final action = await showAnchoredMenu<UserAction>(
      anchorContext: context,
      size: UserActionMenu.size,
      position: (anchor) => Offset(
        anchor.center.dx + _menuRightOffset - UserActionMenu.size.width,
        anchor.center.dy + _menuTopOffset,
      ),
      builder: (_) => const UserActionMenu(),
    );
    if (action == null || !context.mounted) return;

    await runUserAction(
      context: context,
      action: action,
      user: cubit.state.user,
      onUserChanged: cubit.updateUser,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _openMenu(context),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: const Icon(Icons.more_vert_rounded, size: _iconSize),
    );
  }
}
