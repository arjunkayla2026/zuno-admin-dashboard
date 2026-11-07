import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_detail_grid.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_section_label.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_details_header.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_labels.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_total_panel.dart';

class WithdrawalDetailsSheet extends StatelessWidget {
  const WithdrawalDetailsSheet({
    super.key,
    required this.withdrawal,
    required this.onWithdraw,
  });

  static const double _headerGap = 18;
  static const double _labelGap = 12;
  static const double _sectionGap = 22;

  final Withdrawal withdrawal;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, _) = WithdrawalLabels.status(withdrawal);

    return AppSideSheet(
      title: AppStrings.withdrawalDetails,
      subtitle: AppStrings.dotSeparated(withdrawal.withdrawId, statusLabel),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WithdrawalDetailsHeader(withdrawal: withdrawal),
          const SizedBox(height: _headerGap),
          WithdrawalTotalPanel(totalAmount: withdrawal.totalAmount),
          const SizedBox(height: _sectionGap),
          const AppSectionLabel(AppStrings.earnings),
          const SizedBox(height: _labelGap),
          AppDetailGrid(
            items: [
              AppDetailItem(
                AppStrings.date,
                value: DateFormatter.short(withdrawal.date),
              ),
              AppDetailItem(
                AppStrings.totalCallsCount,
                value: NumberFormatter.grouped(withdrawal.callCount),
              ),
              AppDetailItem(
                AppStrings.callDuration,
                value: AppStrings.minutesValue(
                  NumberFormatter.grouped(withdrawal.callMinutes),
                ),
              ),
              AppDetailItem(
                AppStrings.amountEarned,
                value: NumberFormatter.rupees(withdrawal.amountEarned),
              ),
              AppDetailItem(
                AppStrings.surgeChargeSession,
                value: NumberFormatter.rupees(withdrawal.hostCredit),
              ),
              AppDetailItem(
                AppStrings.withdrawAmount,
                value: NumberFormatter.rupees(withdrawal.totalAmount),
              ),
            ],
          ),
          const SizedBox(height: _sectionGap),
          const AppSectionLabel(AppStrings.bankAccount),
          const SizedBox(height: _labelGap),
          AppDetailGrid(
            items: [
              AppDetailItem(
                AppStrings.accountHolderName,
                value: withdrawal.accountHolderName,
              ),
              AppDetailItem(
                AppStrings.branchName,
                value: withdrawal.branchName,
              ),
              AppDetailItem(
                AppStrings.accountNumber,
                value: withdrawal.accountNumber,
                mono: true,
              ),
              AppDetailItem(
                AppStrings.ifscCode,
                value: withdrawal.ifscCode,
                mono: true,
              ),
            ],
          ),
        ],
      ),
      footer: Wrap(
        spacing: AppUtils.spacingSm,
        runSpacing: AppUtils.spacingSm,
        children: [
          AppSecondaryButton(
            label: AppStrings.close,
            onPressed: () => Navigator.of(context).pop(),
          ),
          if (withdrawal.isPending)
            AppPrimaryButton(
              label: AppStrings.withdraw,
              compact: true,
              onPressed: onWithdraw,
            ),
        ],
      ),
    );
  }
}
