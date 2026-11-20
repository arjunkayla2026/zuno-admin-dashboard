import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_refresh_button.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/call_history_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/call_pricing_cubit.dart';

class HostDetailsRefreshButton extends StatelessWidget {
  const HostDetailsRefreshButton({super.key});

  Future<void> _refresh(BuildContext context) async {
    await Future.wait([
      context.read<HostDetailsCubit>().refresh(),
      context.read<CallHistoryCubit>().refresh(),
      context.read<CallPricingCubit>().load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final adjusting = context.select(
      (HostDetailsCubit cubit) => cubit.state.adjusting,
    );

    return AppRefreshButton(
      onRefresh: adjusting ? null : () => _refresh(context),
    );
  }
}
