import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/state/dashboard_cubit.dart';

class DashboardRefreshButton extends StatelessWidget {
  const DashboardRefreshButton({super.key});

  static const double _iconSize = 18;
  static const double _loaderStroke = 2;

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

    return AppSecondaryButton(
      label: AppStrings.refresh,
      onPressed: refreshing ? null : () => _refresh(context),
      leading: refreshing
          ? SizedBox.square(
              dimension: _iconSize,
              child: CircularProgressIndicator(
                strokeWidth: _loaderStroke,
                color: context.appColors.textSecondary,
              ),
            )
          : const Icon(Icons.refresh_rounded, size: _iconSize),
    );
  }
}
