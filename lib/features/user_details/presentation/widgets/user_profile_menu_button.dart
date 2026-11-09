import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_profile_menu_button.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/widgets/user_action_flow.dart';

class UserProfileMenuButton extends StatelessWidget {
  const UserProfileMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProfileMenuButton(
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
