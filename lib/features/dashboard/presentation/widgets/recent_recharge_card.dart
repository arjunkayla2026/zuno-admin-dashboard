import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_empty_state.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_section_card.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/admin_session_cubit.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/widgets/recharge_table.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/widgets/view_all_button.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';

class RecentRechargeCard extends StatelessWidget {
  const RecentRechargeCard({
    super.key,
    required this.status,
    required this.recharges,
    required this.errorMessage,
    required this.onRetry,
  });

  static const double _headerHeight = 60;

  final LoadStatus status;
  final List<RechargeTransaction> recharges;
  final String? errorMessage;
  final VoidCallback onRetry;

  Widget _body() => switch (status) {
    LoadStatus.loading => const AppTableLoadingState(),
    LoadStatus.failure => AppTableErrorState(
      message: errorMessage ?? AppStrings.recordsLoadFailed,
      onRetry: onRetry,
    ),
    LoadStatus.loaded when recharges.isEmpty => const AppEmptyState(
      icon: Icons.receipt_long_outlined,
      title: AppStrings.noRechargesFound,
      message: AppStrings.noRecentRechargesMessage,
    ),
    LoadStatus.loaded => RechargeTable(recharges: recharges),
  };

  @override
  Widget build(BuildContext context) {
    final canViewRecharges = context.select<AdminSessionCubit, bool>(
      (cubit) => cubit.state.account?.canAccess(AdminNavItem.recharge) ?? false,
    );

    return AppSectionCard(
      title: AppStrings.recentRechargeActivity,
      headerHeight: _headerHeight,
      trailing: canViewRecharges
          ? ViewAllButton(
              label: AppStrings.viewAllRecharges,
              onPressed: () =>
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.recharge),
            )
          : null,
      child: _body(),
    );
  }
}
