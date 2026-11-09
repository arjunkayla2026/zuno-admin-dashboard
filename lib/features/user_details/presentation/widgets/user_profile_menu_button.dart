import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_action_menu.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_profile_menu_button.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/widgets/user_action_flow.dart';

class UserProfileMenuButton extends StatelessWidget {
  const UserProfileMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select(
      (UserDetailsCubit cubit) => cubit.state.user.status,
    );

    return AppProfileMenuButton(
      actions: AppActionMenu.accountActions(
        isBlocked: status == UserStatus.blocked,
      ),
      onSelected: (action) {
        final cubit = context.read<UserDetailsCubit>();
        runUserAction(
          context: context,
          action: action,
          user: cubit.state.user,
          onUserChanged: cubit.updateUser,
        );
      },
    );
  }
}
