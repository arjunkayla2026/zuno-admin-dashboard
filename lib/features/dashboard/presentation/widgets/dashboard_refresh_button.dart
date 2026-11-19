import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_refresh_button.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/state/dashboard_cubit.dart';

class DashboardRefreshButton extends StatelessWidget {
  const DashboardRefreshButton({super.key});

  Future<void> _refresh(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final succeeded = await context.read<DashboardCubit>().refresh();
    if (succeeded) return;
    messenger.showSnackBar(
      const SnackBar(content: Text(AppStrings.dashboardRefreshFailed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final refreshing = context.select<DashboardCubit, bool>(
      (cubit) => cubit.state.refreshing,
    );

    return AppRefreshButton(
      refreshing: refreshing,
      onRefresh: () => _refresh(context),
    );
  }
}
