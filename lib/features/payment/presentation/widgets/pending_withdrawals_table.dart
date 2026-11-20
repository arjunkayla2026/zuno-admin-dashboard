import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_state.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_flow.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_selection.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_table_columns.dart';

class PendingWithdrawalsTable extends StatelessWidget {
  const PendingWithdrawalsTable({
    super.key,
    required this.withdrawals,
    required this.state,
    this.firstIndex = 0,
  });

  final List<Withdrawal> withdrawals;
  final PaymentState state;
  final int firstIndex;

  @override
  Widget build(BuildContext context) {
    return AppDataTable(
      columns: [
        WithdrawalSelection.column(context, state),
        ...WithdrawalTableColumns.columns,
        const AppTableColumn('', 90, alignEnd: true),
      ],
      onRowTap: (index) => openWithdrawalDetails(context, withdrawals[index]),
      rows: [
        for (final (index, withdrawal) in withdrawals.indexed)
          [
            WithdrawalSelection.cell(context, state, withdrawal),
            ...WithdrawalTableColumns.cells(
              context,
              withdrawal,
              number: firstIndex + index + 1,
              defaultTdsPercent: PaymentState.tdsPercent,
            ),
            AppPrimaryButton(
              label: AppStrings.withdraw,
              small: true,
              onPressed: state.batchRunning
                  ? null
                  : () => openWithdrawalDetails(context, withdrawal),
            ),
          ],
      ],
    );
  }
}
