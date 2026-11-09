import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_record_count_footer.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_state.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_call_history_tab.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_history_tab_bar.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_wallet_history_tab.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_withdrawal_history_table.dart';

class HostHistoryCard extends StatelessWidget {
  const HostHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tab = context.select((HostDetailsCubit cubit) => cubit.state.tab);
    final withdrawals = context.select(
      (HostDetailsCubit cubit) => cubit.state.withdrawals,
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HostHistoryTabBar(),
          const Divider(color: AppColors.cardBorder),
          switch (tab) {
            HostDetailsTab.calls => const HostCallHistoryTab(),
            HostDetailsTab.withdrawals =>
              withdrawals.isEmpty
                  ? const AppRecordCountFooter(shown: 0, total: 0)
                  : HostWithdrawalHistoryTable(withdrawals: withdrawals),
            HostDetailsTab.wallet => const HostWalletHistoryTab(),
          },
        ],
      ),
    );
  }
}
