import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_refresh_button.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/call_history_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_recharge_history_cubit.dart';

class UserDetailsRefreshButton extends StatelessWidget {
  const UserDetailsRefreshButton({super.key});

  Future<void> _refresh(BuildContext context) async {
    await Future.wait([
      context.read<UserDetailsCubit>().refresh(),
      context.read<CallHistoryCubit>().refresh(),
      context.read<UserRechargeHistoryCubit>().reload(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AppRefreshButton(onRefresh: () => _refresh(context));
  }
}
