import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_detail_grid.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_section_label.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_labels.dart';

class WithdrawalFailureDetails extends StatelessWidget {
  const WithdrawalFailureDetails({super.key, required this.withdrawal});

  static const double _labelGap = 12;

  final Withdrawal withdrawal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionLabel(
          withdrawal.isFailed
              ? AppStrings.failureDetails
              : AppStrings.lastFailureDetails,
        ),
        const SizedBox(height: _labelGap),
        AppDetailGrid(
          items: [
            AppDetailItem(
              AppStrings.failureReason,
              value: WithdrawalLabels.failure(withdrawal),
            ),
            AppDetailItem(
              AppStrings.failedAttempts,
              value: '${withdrawal.failureCount}',
            ),
            if (withdrawal.failedOn case final failedOn?)
              AppDetailItem(
                AppStrings.failedOn,
                value: DateFormatter.short(failedOn),
              ),
            if (withdrawal.failedByName case final failedBy?)
              AppDetailItem(AppStrings.failedBy, value: failedBy),
            if (withdrawal.retriedOn case final retriedOn?
                when !withdrawal.isFailed)
              AppDetailItem(
                AppStrings.retriedOn,
                value: DateFormatter.short(retriedOn),
              ),
            if (withdrawal.isPending)
              AppDetailItem(
                AppStrings.bankReference,
                value: withdrawal.bankReference,
                mono: true,
              ),
          ],
        ),
      ],
    );
  }
}
