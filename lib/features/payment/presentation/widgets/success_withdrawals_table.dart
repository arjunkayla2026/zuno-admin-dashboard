import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_avatar_name_cell.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_flow.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_labels.dart';

class SuccessWithdrawalsTable extends StatelessWidget {
  const SuccessWithdrawalsTable({
    super.key,
    required this.withdrawals,
    required this.defaultTdsPercent,
  });

  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.date, 112),
    AppTableColumn(AppStrings.hostName, 140),
    AppTableColumn(AppStrings.hostId, 96),
    AppTableColumn(AppStrings.phoneNumber, 148),
    AppTableColumn(AppStrings.totalCallsCount, 124, alignEnd: true),
    AppTableColumn(AppStrings.duration, 104, alignEnd: true),
    AppTableColumn(AppStrings.amountEarned, 128, alignEnd: true),
    AppTableColumn(AppStrings.withdrawalAmount, 150, alignEnd: true),
    AppTableColumn(AppStrings.tdsCutAmount, 132, alignEnd: true),
    AppTableColumn(AppStrings.appliedTdsPercent, 120, alignEnd: true),
    AppTableColumn(AppStrings.totalReceivableAmount, 180, alignEnd: true),
    AppTableColumn('', 32),
    AppTableColumn(AppStrings.withdrawStatus, 124),
  ];

  final List<Withdrawal> withdrawals;
  final int defaultTdsPercent;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);
    final strong = cell.copyWith(fontWeight: FontWeight.w700);
    final mono = AppTextStyles.monoSmall.copyWith(color: textColor);

    return AppDataTable(
      columns: _columns,
      onRowTap: (index) => openWithdrawalDetails(context, withdrawals[index]),
      rows: [
        for (final withdrawal in withdrawals)
          () {
            final tds = withdrawal.appliedTdsPercent ?? defaultTdsPercent;
            final (statusLabel, status) = WithdrawalLabels.status(withdrawal);
            return [
              Text(DateFormatter.short(withdrawal.settledDate), style: cell),
              AppAvatarNameCell(
                initials: withdrawal.initials,
                avatarIndex: withdrawal.avatarIndex,
                name: withdrawal.hostName,
              ),
              Text(withdrawal.hostUserId, style: mono),
              Text(withdrawal.phone, style: mono),
              Text(NumberFormatter.grouped(withdrawal.callCount), style: cell),
              Text(
                AppStrings.minutesValue(
                  NumberFormatter.grouped(withdrawal.callMinutes),
                ),
                style: cell,
              ),
              Text(
                NumberFormatter.rupeesAmount(withdrawal.amountEarned),
                style: cell,
              ),
              Text(
                NumberFormatter.rupeesAmount(withdrawal.totalAmount),
                style: cell,
              ),
              Text(
                NumberFormatter.rupeesAmount(withdrawal.tdsAmount(tds)),
                style: cell,
              ),
              Text(AppStrings.percentValue(tds), style: cell),
              Text(
                NumberFormatter.rupeesAmount(withdrawal.receivableAmount(tds)),
                style: strong,
              ),
              const SizedBox.shrink(),
              AppStatusBadge(label: statusLabel, status: status),
            ];
          }(),
      ],
    );
  }
}
