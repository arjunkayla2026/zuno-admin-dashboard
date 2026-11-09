import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_record_count_footer.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_footer.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_underline_tabs.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_cubit.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_state.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/payment_toolbar.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/pending_withdrawals_table.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/success_withdrawals_table.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawals_table.dart';

class PaymentTabsCard extends StatelessWidget {
  const PaymentTabsCard({super.key});

  static const double _emptyHeight = 160;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        final cubit = context.read<PaymentCubit>();
        final isPending = state.tab == PaymentTab.pending;
        final rows = isPending
            ? state.visibleWithdrawals
            : state.pageWithdrawals;

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
              AppUnderlineTabs<PaymentTab>(
                tabs: const {
                  PaymentTab.withdrawalList: AppStrings.withdrawalList,
                  PaymentTab.pending: AppStrings.pendingTab,
                  PaymentTab.success: AppStrings.successTab,
                },
                counts: {
                  PaymentTab.withdrawalList: state.withdrawals.length,
                  PaymentTab.pending: state.pendingCount,
                  PaymentTab.success: state.successCount,
                },
                value: state.tab,
                onChanged: cubit.selectTab,
              ),
              const Divider(color: AppColors.cardBorder),
              const PaymentToolbar(),
              switch (state.tab) {
                PaymentTab.withdrawalList => WithdrawalsTable(
                  withdrawals: rows,
                ),
                PaymentTab.pending => PendingWithdrawalsTable(
                  withdrawals: rows,
                ),
                PaymentTab.success => SuccessWithdrawalsTable(
                  withdrawals: rows,
                  defaultTdsPercent: state.tdsPercent,
                ),
              },
              if (rows.isEmpty)
                SizedBox(
                  height: _emptyHeight,
                  child: Center(
                    child: Text(
                      AppStrings.noWithdrawals,
                      style: AppTextStyles.tableCell.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else if (isPending)
                AppRecordCountFooter(
                  shown: rows.length,
                  total: state.pendingCount,
                )
              else
                AppTableFooter(
                  firstIndex: state.firstIndex,
                  shownCount: rows.length,
                  totalCount: state.visibleWithdrawals.length,
                  currentPage: state.page,
                  totalPages: state.totalPages,
                  onPageChanged: cubit.goToPage,
                ),
            ],
          ),
        );
      },
    );
  }
}
