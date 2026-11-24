import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/di/injection_container.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_participant.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/call_history_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_details_content.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_details_shell.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/call_pricing_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_actions_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_details_arguments.dart';

class HostDetailsView extends StatelessWidget {
  const HostDetailsView({super.key, required this.arguments});

  final HostDetailsArguments arguments;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<HostDetailsCubit>(param1: arguments)..load(),
        ),
        BlocProvider(
          create: (_) => getIt<CallHistoryCubit>(
            param1: CallParticipant.host(arguments.host.hostId),
          )..load(),
        ),
        BlocProvider(create: (_) => getIt<CallPricingCubit>()..load()),
        BlocProvider(create: (_) => getIt<HostActionsCubit>()),
      ],
      child: const HostDetailsShell(child: HostDetailsContent()),
    );
  }
}
