import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_checkbox.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_cubit.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_state.dart';

abstract final class WithdrawalSelection {
  static const double _width = 44;

  static AppTableColumn column(BuildContext context, PaymentState state) {
    final cubit = context.read<PaymentCubit>();
    final value = state.pageSelection;
    final canToggle = state.selectableRows.isNotEmpty && !state.batchRunning;
    return AppTableColumn(
      '',
      _width,
      header: AppTableCheckbox(
        value: value,
        onToggle: canToggle ? () => cubit.setPageSelected(value != true) : null,
      ),
    );
  }

  static Widget cell(
    BuildContext context,
    PaymentState state,
    Withdrawal withdrawal,
  ) {
    final cubit = context.read<PaymentCubit>();
    final canToggle = state.canSelect(withdrawal) && !state.batchRunning;
    return AppTableCheckbox(
      value: state.isSelected(withdrawal),
      onToggle: canToggle ? () => cubit.toggleSelected(withdrawal) : null,
    );
  }
}
