import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/di/injection_container.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_lookup_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_lookup_state.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/user_details_shell.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/user_details_view.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_details_arguments.dart';

class UserDetailsRouteLoader extends StatelessWidget {
  const UserDetailsRouteLoader({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UserLookupCubit>(param1: userId)..load(),
      child: BlocBuilder<UserLookupCubit, UserLookupState>(
        builder: (context, state) => switch (state.status) {
          LoadStatus.loading => const UserDetailsShell(
            child: AppTableLoadingState(),
          ),
          LoadStatus.failure => UserDetailsShell(
            child: AppTableErrorState(
              message: state.errorMessage ?? AppStrings.recordsLoadFailed,
              onRetry: context.read<UserLookupCubit>().load,
            ),
          ),
          LoadStatus.loaded => switch (state.user) {
            final user? => UserDetailsView(
              arguments: UserDetailsArguments(user: user),
            ),
            null => UserDetailsShell.message(
              message: AppStrings.userUnavailable,
            ),
          },
        },
      ),
    );
  }
}
