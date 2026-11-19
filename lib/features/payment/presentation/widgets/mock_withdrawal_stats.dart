import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_stat_cards.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/mock_withdrawal_summary.dart';

class MockWithdrawalStats extends StatelessWidget {
  const MockWithdrawalStats({super.key, required this.summary});

  final MockWithdrawalSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppStatCards(
      dense: true,
      filled: true,
      stats: [
        AppStat(
          label: AppStrings.totalPendingWithdrawals,
          value: NumberFormatter.rupeesAmount(summary.pendingAmount),
          unit: AppStrings.payoutCount(summary.pendingCount),
        ),
        AppStat(
          label: AppStrings.totalSuccessfulWithdrawals,
          value: NumberFormatter.rupeesAmount(summary.successAmount),
          unit: AppStrings.payoutCount(summary.successCount),
        ),
        AppStat(
          label: AppStrings.totalRejectedWithdrawals,
          value: NumberFormatter.rupeesAmount(summary.rejectedAmount),
          unit: AppStrings.payoutCount(summary.rejectedCount),
        ),
        AppStat(
          label: AppStrings.totalMockWithdrawalAmount,
          value: NumberFormatter.rupeesAmount(summary.totalAmount),
        ),
        AppStat(
          label: AppStrings.totalSuccessfullyWithdrawnAmount,
          value: NumberFormatter.rupeesAmount(summary.totalWithdrawn),
        ),
      ],
    );
  }
}
