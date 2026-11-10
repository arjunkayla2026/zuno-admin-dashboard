import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_stat_cards.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/state/recharge_cubit.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/state/recharge_state.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/widgets/recharge_table_card.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/widgets/recharge_toolbar.dart';

class RechargeContent extends StatelessWidget {
  const RechargeContent({super.key});

  static const double _toolbarGap = 10;
  static const double _statsGap = 12;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(32, 48, 32, 32);
  static const EdgeInsets _mobilePadding = EdgeInsets.all(AppUtils.spacingLg);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppUtils.isMobile(context) ? _mobilePadding : _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RechargeToolbar(),
          const SizedBox(height: _toolbarGap),
          BlocBuilder<RechargeCubit, RechargeState>(
            builder: (context, state) {
              final totals = state.totals;
              String amount(double Function(RechargeTotals totals) read) =>
                  totals == null
                  ? AppStrings.emptyValue
                  : NumberFormatter.rupeesAmount(read(totals));

              return AppStatCards(
                dense: true,
                stats: [
                  AppStat(
                    label: AppStrings.totalRechargeCount,
                    value: totals == null
                        ? AppStrings.emptyValue
                        : NumberFormatter.grouped(totals.rechargeCount),
                  ),
                  AppStat(
                    label: AppStrings.totalRechargeAmount,
                    value: amount((totals) => totals.rechargeAmount),
                  ),
                  AppStat(
                    label: AppStrings.totalCreditAmount,
                    value: amount((totals) => totals.creditAmount),
                  ),
                  AppStat(
                    label: AppStrings.totalDebitAmount,
                    value: amount((totals) => totals.debitAmount),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: _statsGap),
          const RechargeTableCard(),
        ],
      ),
    );
  }
}
