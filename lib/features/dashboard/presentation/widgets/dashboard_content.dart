import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/state/dashboard_cubit.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/widgets/dashboard_labels.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/widgets/recent_recharge_card.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/widgets/stat_section.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  static const double _sectionGap = 16;
  static const double _tableGap = 0;
  static const double _callTileHeight = 81;
  static const double _headerGap = 15;
  static const double _sideBySideWidth = 900;
  static const double _columnGap = 20;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(32, 24, 32, 32);
  static const EdgeInsets _mobilePadding = EdgeInsets.all(AppUtils.spacingLg);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final rangeLabel = DashboardLabels.range(state);
        final cubit = context.read<DashboardCubit>();
        final revenue = StatSection(
          title: AppStrings.revenueSummary,
          rangeLabel: rangeLabel,
          stats: DashboardLabels.revenue(state),
          columns: 3,
          errorMessage: state.revenueStatus == LoadStatus.failure
              ? state.revenueError
              : null,
          onRetry: cubit.retryRevenue,
        );
        final users = StatSection(
          title: AppStrings.userStatistics,
          rangeLabel: rangeLabel,
          stats: DashboardLabels.users(state),
          columns: 3,
          errorMessage: state.accountsStatus == LoadStatus.failure
              ? state.accountsError
              : null,
          onRetry: cubit.retryAccounts,
        );

        return SingleChildScrollView(
          padding: AppUtils.isMobile(context) ? _mobilePadding : _padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DashboardHeader(),
              const SizedBox(height: _headerGap),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < _sideBySideWidth) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        revenue,
                        const SizedBox(height: _sectionGap),
                        users,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: revenue),
                      const SizedBox(width: _columnGap),
                      Expanded(child: users),
                    ],
                  );
                },
              ),
              const SizedBox(height: _sectionGap),
              StatSection(
                title: AppStrings.callStatistics,
                rangeLabel: rangeLabel,
                stats: DashboardLabels.calls(state),
                columns: 5,
                tileMinHeight: _callTileHeight,
                errorMessage: state.callsStatus == LoadStatus.failure
                    ? state.callsError
                    : null,
                onRetry: cubit.retryCallStats,
              ),
              const SizedBox(height: _tableGap),
              RecentRechargeCard(
                status: state.recentStatus,
                recharges: state.recentRecharges,
                errorMessage: state.recentError,
                onRetry: cubit.retryRecent,
              ),
            ],
          ),
        );
      },
    );
  }
}
