import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class HostWithdrawalHistoryTable extends StatelessWidget {
  const HostWithdrawalHistoryTable({super.key, required this.withdrawals});

  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.withdrawDate, 108),
    AppTableColumn(AppStrings.callCount, 70, alignEnd: true),
    AppTableColumn(AppStrings.callDuration, 92, alignEnd: true),
    AppTableColumn(AppStrings.amountEarned, 108, alignEnd: true),
    AppTableColumn(AppStrings.surgeChargeSession, 145, alignEnd: true),
    AppTableColumn(AppStrings.withdrawAmount, 130, alignEnd: true),
    AppTableColumn('', 22),
    AppTableColumn(AppStrings.branchName, 152),
    AppTableColumn(AppStrings.accountHolderName, 150),
    AppTableColumn(AppStrings.accountNumber, 120),
    AppTableColumn(AppStrings.ifscCode, 105),
    AppTableColumn(AppStrings.withdrawId, 93),
    AppTableColumn(AppStrings.status, 100),
  ];

  final List<Withdrawal> withdrawals;

  static (String, AppStatus) _status(WithdrawalStatus status) =>
      switch (status) {
        WithdrawalStatus.pending => (AppStrings.pending, AppStatus.pending),
        WithdrawalStatus.success => (AppStrings.success, AppStatus.active),
      };

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);
    final strong = cell.copyWith(fontWeight: FontWeight.w700);
    final mono = AppTextStyles.monoSmall.copyWith(color: textColor);

    return AppDataTable(
      columns: _columns,
      rows: [
        for (final withdrawal in withdrawals)
          () {
            final (statusLabel, status) = _status(withdrawal.status);
            final surge = withdrawal.surgeEarnings;
            return [
              Text(DateFormatter.short(withdrawal.settledDate), style: cell),
              Text('${withdrawal.callCount}', style: cell),
              Text(AppStrings.minutes(withdrawal.callMinutes), style: cell),
              Text(
                NumberFormatter.rupeesAmount(withdrawal.amountEarned),
                style: strong,
              ),
              Text(
                surge > 0
                    ? NumberFormatter.rupeesAmount(surge)
                    : AppStrings.emptyValue,
                style: cell,
              ),
              Text(
                NumberFormatter.rupeesAmount(withdrawal.totalAmount),
                style: strong,
              ),
              const SizedBox.shrink(),
              Text(withdrawal.branchName, style: cell),
              Text(withdrawal.accountHolderName, style: cell),
              Text(withdrawal.accountNumber, style: cell),
              Text(withdrawal.ifscCode, style: mono),
              Text(withdrawal.withdrawId, style: mono),
              AppStatusBadge(label: statusLabel, status: status),
            ];
          }(),
      ],
    );
  }
}
