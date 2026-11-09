import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_call_filter_bar.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_record_count_footer.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_state.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_call_history_table.dart';

class HostCallHistoryTab extends StatelessWidget {
  const HostCallHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostDetailsCubit, HostDetailsState>(
      builder: (context, state) {
        final cubit = context.read<HostDetailsCubit>();
        final calls = state.filteredCalls;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCallFilterBar(
              typeFilter: state.typeFilter,
              onTypeChanged: cubit.selectType,
              dateMode: state.dateMode,
              onDateModeChanged: cubit.selectDateMode,
              singleDate: state.singleDate,
              onSingleDateChanged: cubit.setSingleDate,
              rangeStart: state.rangeStart,
              onRangeStartChanged: cubit.setRangeStart,
              rangeEnd: state.rangeEnd,
              onRangeEndChanged: cubit.setRangeEnd,
              callCount: calls.length,
            ),
            HostCallHistoryTable(calls: calls),
            AppRecordCountFooter(
              shown: calls.length,
              total: state.calls.length,
            ),
          ],
        );
      },
    );
  }
}
