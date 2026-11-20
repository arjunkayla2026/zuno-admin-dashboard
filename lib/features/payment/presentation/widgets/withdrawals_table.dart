import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_avatar_name_cell.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/mock_withdrawal_badge.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_state.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_flow.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_selection.dart';

class WithdrawalsTable extends StatelessWidget {
  const WithdrawalsTable({
    super.key,
    required this.withdrawals,
    required this.state,
  });

  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.date, 112),
    AppTableColumn(AppStrings.hostName, 186),
    AppTableColumn(AppStrings.hostId, 118),
    AppTableColumn(AppStrings.withdrawId, 138),
    AppTableColumn(AppStrings.totalCallsCount, 140, alignEnd: true),
    AppTableColumn(AppStrings.amountEarned, 150, alignEnd: true),
    AppTableColumn(AppStrings.withdrawAmount, 170, alignEnd: true),
    AppTableColumn('', 80, alignEnd: true),
  ];

  final List<Withdrawal> withdrawals;
  final PaymentState state;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);
    final strong = cell.copyWith(fontWeight: FontWeight.w700);
    final mono = AppTextStyles.monoSmall.copyWith(color: textColor);
    final identifier = AppTextStyles.identifier.copyWith(color: textColor);

    return AppDataTable(
      columns: [WithdrawalSelection.column(context, state), ..._columns],
      onRowTap: (index) => openWithdrawalDetails(context, withdrawals[index]),
      rows: [
        for (final withdrawal in withdrawals)
          [
            WithdrawalSelection.cell(context, state, withdrawal),
            Text(DateFormatter.short(withdrawal.date), style: cell),
            AppAvatarNameCell(
              initials: withdrawal.initials,
              avatarIndex: withdrawal.avatarIndex,
              name: withdrawal.hostName,
              photoUserId: withdrawal.hostId,
              badge: MockWithdrawalBadge.of(withdrawal),
            ),
            Text(withdrawal.hostUserId, style: identifier),
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
