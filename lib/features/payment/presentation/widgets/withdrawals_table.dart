import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_avatar_name_cell.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_flow.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_labels.dart';

class WithdrawalsTable extends StatelessWidget {
  const WithdrawalsTable({super.key, required this.withdrawals});

  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.date, 155),
    AppTableColumn(AppStrings.hostName, 186),
    AppTableColumn(AppStrings.hostId, 118),
    AppTableColumn(AppStrings.withdrawId, 138),
    AppTableColumn(AppStrings.totalCallsCount, 155, alignEnd: true),
    AppTableColumn(AppStrings.amountEarned, 168, alignEnd: true),
    AppTableColumn(AppStrings.withdrawAmount, 190, alignEnd: true),
    AppTableColumn('', 26),
    AppTableColumn(AppStrings.status, 150),
    AppTableColumn('', 80, alignEnd: true),
  ];

  final List<Withdrawal> withdrawals;

  static Widget _statusBadge(Withdrawal withdrawal) {
    final (label, status) = WithdrawalLabels.status(withdrawal);
    return AppStatusBadge(label: label, status: status);
  }

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
          [
            Text(DateFormatter.short(withdrawal.date), style: cell),
            AppAvatarNameCell(
              initials: withdrawal.initials,
              avatarIndex: withdrawal.avatarIndex,
              name: withdrawal.hostName,
            ),
            Text(withdrawal.hostUserId, style: mono),
            Text(withdrawal.withdrawId, style: mono),
            Text(NumberFormatter.grouped(withdrawal.callCount), style: cell),
            Text(
              NumberFormatter.rupeesAmount(withdrawal.amountEarned),
              style: cell,
            ),
            Text(
              NumberFormatter.rupeesAmount(withdrawal.totalAmount),
              style: strong,
            ),
            const SizedBox.shrink(),
            _statusBadge(withdrawal),
            AppSecondaryButton(
              label: AppStrings.view,
              small: true,
              onPressed: () => openWithdrawalDetails(context, withdrawal),
            ),
          ],
      ],
    );
  }
}
