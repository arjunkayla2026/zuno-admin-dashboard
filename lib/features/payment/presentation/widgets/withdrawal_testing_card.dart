import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_error_banner.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_section_card.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/mock_withdrawals_cubit.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/mock_withdrawals_state.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/mock_host_withdrawn_totals.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/mock_pending_withdrawals.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/mock_withdrawal_flow.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/mock_withdrawal_stats.dart';

/// Staging-only controls for trying the payout flow on mock hosts.
class WithdrawalTestingCard extends StatelessWidget {
  const WithdrawalTestingCard({super.key});

  static const EdgeInsets _padding = EdgeInsets.all(AppUtils.spacingLg);
  static const double _progressSize = 24;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: AppStrings.withdrawalWorkflowTesting,
      subtitle: AppStrings.withdrawalWorkflowTestingNote,
      child: BlocBuilder<MockWithdrawalsCubit, MockWithdrawalsState>(
        builder: (context, state) {
          final summary = state.summary;
          return Padding(
            padding: _padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: AppUtils.spacingSm,
                  runSpacing: AppUtils.spacingSm,
                  children: [
                    AppPrimaryButton(
                      label: state.action == MockWithdrawalsAction.generating
                          ? AppStrings.generatingMockWithdrawals
                          : AppStrings.generateMockWithdrawals,
                      compact: true,
                      onPressed: state.isBusy
                          ? null
                          : () => generateMockWithdrawals(context),
                    ),
                    AppSecondaryButton(
                      label: state.action == MockWithdrawalsAction.clearing
                          ? AppStrings.clearingMockData
                          : AppStrings.clearMockData,
                      destructive: true,
                      onPressed: state.isBusy || summary.isEmpty
                          ? null
                          : () => clearMockWithdrawals(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppUtils.spacingLg),
                if (state.status == LoadStatus.failure)
                  AppErrorBanner(
                    message:
                        state.errorMessage ?? AppStrings.mockDataLoadFailed,
                  )
                else if (state.status == LoadStatus.loading && summary.isEmpty)
                  const Center(
                    child: SizedBox.square(
                      dimension: _progressSize,
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (summary.isEmpty)
                  Text(
                    AppStrings.noMockWithdrawals,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  )
                else ...[
                  MockWithdrawalStats(summary: summary),
                  const SizedBox(height: AppUtils.spacingXl),
                  MockPendingWithdrawals(withdrawals: summary.pending),
                  const SizedBox(height: AppUtils.spacingXl),
                  MockHostWithdrawnTotals(hosts: summary.hosts),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
