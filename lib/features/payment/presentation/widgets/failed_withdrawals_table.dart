import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_avatar_name_cell.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_state.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_flow.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_labels.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_selection.dart';

class FailedWithdrawalsTable extends StatelessWidget {
  const FailedWithdrawalsTable({
    super.key,
    required this.withdrawals,
    required this.state,
    this.firstIndex = 0,
  });

  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.number, 60),
    AppTableColumn(AppStrings.failedOn, 112),
    AppTableColumn(AppStrings.hostName, 140),
    AppTableColumn(AppStrings.hostId, 96),
    AppTableColumn(AppStrings.payoutPeriod, 190),
    AppTableColumn(AppStrings.totalAmount, 120, alignEnd: true),
    AppTableColumn('', 21),
    AppTableColumn(AppStrings.failureReason, 240),
    AppTableColumn(AppStrings.failedAttempts, 120, alignEnd: true),
    AppTableColumn(AppStrings.failedBy, 140),
    AppTableColumn(AppStrings.bankAccount, 150),
    AppTableColumn('', 124, alignEnd: true),
  ];

  final List<Withdrawal> withdrawals;
  final PaymentState state;
  final int firstIndex;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);
    final strong = cell.copyWith(fontWeight: FontWeight.w700);
    final identifier = AppTextStyles.identifier.copyWith(color: textColor);

    return AppDataTable(
      columns: [WithdrawalSelection.column(context, state), ..._columns],
      onRowTap: (index) => openWithdrawalDetails(context, withdrawals[index]),
      rows: [
        for (final (index, withdrawal) in withdrawals.indexed)
          () {
            final (bankLabel, bankStatus) = WithdrawalLabels.bankAccount(
              withdrawal,
            );
            return [
              WithdrawalSelection.cell(context, state, withdrawal),
              Text('${firstIndex + index + 1}', style: cell),
              Text(DateFormatter.short(withdrawal.settledDate), style: cell),
              AppAvatarNameCell(
                initials: withdrawal.initials,
                avatarIndex: withdrawal.avatarIndex,
                name: withdrawal.hostName,
                photoUserId: withdrawal.hostId,
              ),
              Text(withdrawal.hostUserId, style: identifier),
              Text(WithdrawalLabels.period(withdrawal), style: cell),
              Text(
                NumberFormatter.rupeesAmount(withdrawal.totalAmount),
                style: strong,
              ),
              const SizedBox.shrink(),
              Text(WithdrawalLabels.failure(withdrawal), style: cell),
              Text(
                NumberFormatter.grouped(withdrawal.failureCount),
                style: cell,
              ),
              Text(
                withdrawal.failedByName ?? AppStrings.emptyValue,
                style: cell,
              ),
              AppStatusBadge(label: bankLabel, status: bankStatus),
              AppPrimaryButton(
                label: AppStrings.retryPayout,
                small: true,
                onPressed: state.batchRunning
                    ? null
                    : () => openWithdrawalDetails(context, withdrawal),
              ),
            ];
          }(),
      ],
    );
  }
}
