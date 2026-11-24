import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/di/injection_container.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_lookup_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_lookup_state.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_details_shell.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_details_view.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_details_arguments.dart';

class HostDetailsRouteLoader extends StatelessWidget {
  const HostDetailsRouteLoader({super.key, required this.hostId});

  final String hostId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HostLookupCubit>(param1: hostId)..load(),
      child: BlocBuilder<HostLookupCubit, HostLookupState>(
        builder: (context, state) => switch (state.status) {
          LoadStatus.loading => const HostDetailsShell(
            child: AppTableLoadingState(),
          ),
          LoadStatus.failure => HostDetailsShell(
            child: AppTableErrorState(
              message: state.errorMessage ?? AppStrings.recordsLoadFailed,
              onRetry: context.read<HostLookupCubit>().load,
            ),
          ),
          LoadStatus.loaded => switch (state.host) {
            final host? => HostDetailsView(
              arguments: HostDetailsArguments(host: host),
            ),
            null => HostDetailsShell.message(
              message: AppStrings.hostUnavailable,
            ),
          },
        },
      ),
    );
  }
}
