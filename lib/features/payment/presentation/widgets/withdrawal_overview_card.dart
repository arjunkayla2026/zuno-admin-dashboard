import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_stat_cards.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_cubit.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_state.dart';

class WithdrawalOverviewCard extends StatelessWidget {
  const WithdrawalOverviewCard({super.key});

  static const EdgeInsets _padding = EdgeInsets.all(14);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: _padding,
                child: Wrap(
                  spacing: AppUtils.spacingSm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      AppStrings.upcomingWithdrawalOverview,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      switch (state.minimumPayout) {
                        final minimum? => AppStrings.withdrawalOverviewNote(
                          state.pendingCount,
                          NumberFormatter.rupeesAmount(minimum),
                        ),
                        null => AppStrings.withdrawalOverviewNoteUnset(
                          state.pendingCount,
                        ),
                      },
                      style: AppTextStyles.tableFootnote.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.cardBorder),
              Padding(
                padding: _padding,
                child: AppStatCards(
                  dense: true,
                  filled: true,
                  stats: [
                    AppStat(
                      label: AppStrings.hostRevenue,
                      value: NumberFormatter.rupeesAmount(state.pendingEarned),
                    ),
                    AppStat(
                      label: AppStrings.duration,
                      value: NumberFormatter.grouped(state.pendingMinutes),
                      unit: AppStrings.minutesUnit,
                    ),
                    AppStat(
                      label: AppStrings.totalHostCredit,
                      value: NumberFormatter.rupeesAmount(state.pendingCredit),
                    ),
                    AppStat(
                      label: AppStrings.totalHostRevenueStat,
                      value: NumberFormatter.rupeesAmount(state.pendingTotal),
                    ),
                    AppStat(
                      label: AppStrings.totalWithdraw,
                      value: NumberFormatter.rupeesAmount(state.pendingTotal),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
