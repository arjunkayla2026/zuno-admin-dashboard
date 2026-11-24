import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/di/injection_container.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_participant.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/call_history_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/call_pricing_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/add_recharge_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_recharge_history_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/user_details_content.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/user_details_shell.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_actions_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_details_arguments.dart';

class UserDetailsView extends StatelessWidget {
  const UserDetailsView({super.key, required this.arguments});

  final UserDetailsArguments arguments;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<UserDetailsCubit>(param1: arguments)
            ..loadRechargeSummary()
            ..loadDeletedAccountProfit(),
        ),
        BlocProvider(
          create: (_) => getIt<CallHistoryCubit>(
            param1: CallParticipant.user(arguments.user.id),
          )..load(),
        ),
        BlocProvider(create: (_) => getIt<CallPricingCubit>()..load()),
        BlocProvider(create: (_) => getIt<UserActionsCubit>()),
        BlocProvider(create: (_) => getIt<AddRechargeCubit>()),
        BlocProvider(
          create: (_) =>
              getIt<UserRechargeHistoryCubit>(param1: arguments.user.id)
                ..load(),
        ),
      ],
      child: const UserDetailsShell(child: UserDetailsContent()),
    );
  }
}
