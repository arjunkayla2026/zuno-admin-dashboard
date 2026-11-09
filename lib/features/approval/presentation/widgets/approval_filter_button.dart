import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_date_filter_button.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_cubit.dart';

class ApprovalFilterButton extends StatelessWidget {
  const ApprovalFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ApprovalCubit>();
    final state = context.watch<ApprovalCubit>().state;

    return AppDateFilterButton(
      value: state.dateFilter,
      today: state.today,
      customRange: state.customRange,
      onFilterSelected: cubit.selectDateFilter,
      onCustomRangeSelected: cubit.selectCustomRange,
    );
  }
}
