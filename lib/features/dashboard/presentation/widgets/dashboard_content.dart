import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/state/dashboard_cubit.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/widgets/dashboard_header.dart';
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
        final rangeLabel = state.isCustomRange
            ? '${DateFormatter.short(state.customStart)} – '
                  '${DateFormatter.short(state.customEnd)}'
            : AppStrings.today;
        final revenue = StatSection(
          title: AppStrings.revenueSummary,
          rangeLabel: rangeLabel,
          stats: state.stats.revenue,
          columns: 3,
        );
        final users = StatSection(
          title: AppStrings.userStatistics,
          rangeLabel: rangeLabel,
          stats: state.stats.users,
          columns: 3,
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
                stats: state.stats.calls,
                columns: 5,
                tileMinHeight: _callTileHeight,
              ),
              const SizedBox(height: _tableGap),
              RecentRechargeCard(recharges: state.recentRecharges),
            ],
          ),
        );
      },
    );
  }
}
