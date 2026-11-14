import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_avatar_name_cell.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_flow.dart';

class PendingWithdrawalsTable extends StatelessWidget {
  const PendingWithdrawalsTable({
    super.key,
    required this.withdrawals,
    this.firstIndex = 0,
  });

  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.number, 70),
    AppTableColumn(AppStrings.hostName, 126),
    AppTableColumn(AppStrings.hostId, 80),
    AppTableColumn(AppStrings.totalCallsCount, 110, alignEnd: true),
    AppTableColumn(AppStrings.callDurationMinutes, 133, alignEnd: true),
    AppTableColumn(AppStrings.amountEarned, 117, alignEnd: true),
    AppTableColumn(AppStrings.totalAmount, 101, alignEnd: true),
    AppTableColumn('', 21),
    AppTableColumn(AppStrings.branchName, 170),
    AppTableColumn(AppStrings.accountHolderName, 152),
    AppTableColumn(AppStrings.accountNumber, 123),
    AppTableColumn(AppStrings.ifscCode, 110),
    AppTableColumn('', 90, alignEnd: true),
  ];

  final List<Withdrawal> withdrawals;
  final int firstIndex;

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
        for (final (index, withdrawal) in withdrawals.indexed)
          [
            Text('${firstIndex + index + 1}', style: cell),
            AppAvatarNameCell(
              initials: withdrawal.initials,
              avatarIndex: withdrawal.avatarIndex,
              name: withdrawal.hostName,
            ),
            Text(withdrawal.hostUserId, style: mono),
            Text(NumberFormatter.grouped(withdrawal.callCount), style: cell),
            Text(NumberFormatter.grouped(withdrawal.callMinutes), style: cell),
            Text(
              NumberFormatter.rupeesAmount(withdrawal.amountEarned),
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
            AppPrimaryButton(
              label: AppStrings.withdraw,
              small: true,
              onPressed: () => openWithdrawalDetails(context, withdrawal),
            ),
          ],
      ],
    );
  }
}
