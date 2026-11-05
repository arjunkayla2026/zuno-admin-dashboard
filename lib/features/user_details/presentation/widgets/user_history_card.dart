import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_state.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/call_history_tab.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/history_tabs.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/recharge_history_tab.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

class UserHistoryCard extends StatelessWidget {
  const UserHistoryCard({super.key, required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    final tab = context.select((UserDetailsCubit cubit) => cubit.state.tab);

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
          const HistoryTabs(),
          const Divider(color: AppColors.cardBorder),
          switch (tab) {
            UserDetailsTab.calls => const CallHistoryTab(),
            UserDetailsTab.recharges => RechargeHistoryTab(user: user),
          },
        ],
      ),
    );
  }
}
