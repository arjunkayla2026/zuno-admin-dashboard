import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_back_link.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_stat_cards.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_history_card.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_overview_section.dart';

class HostDetailsContent extends StatelessWidget {
  const HostDetailsContent({super.key});

  static const double _backGap = 18;
  static const double _sectionGap = 18;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(32, 24, 32, 32);
  static const EdgeInsets _mobilePadding = EdgeInsets.all(AppUtils.spacingLg);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppUtils.isMobile(context) ? _mobilePadding : _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppBackLink(
            label: AppStrings.backToHosts,
            fallbackRoute: AppRoutes.hostManagement,
          ),
          const SizedBox(height: _backGap),
          const HostOverviewSection(),
          const SizedBox(height: _sectionGap),
          AppStatCards(
            stats: context.select(
              (HostDetailsCubit cubit) => cubit.state.stats,
            ),
          ),
          const SizedBox(height: _sectionGap),
          const HostHistoryCard(),
        ],
      ),
    );
  }
}
