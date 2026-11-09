import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_filter_dropdown.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_search_field.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/calls_cubit.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/calls_state.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/widgets/total_calls_card.dart';

class CallsToolbar extends StatelessWidget {
  const CallsToolbar({super.key});

  static const double _searchWidth = 480;
  static const double _gap = 4;
  static const double _runGap = 8;
  static const double _statusWidth = 220;
  static const double _typeWidth = 208;
  static const double _periodWidth = 122;

  static String _dateLabel(CallDateFilter date) => switch (date) {
    CallDateFilter.today => AppStrings.today,
    CallDateFilter.yesterday => AppStrings.yesterday,
  };

  static String _statusLabel(CallStatusFilter status) => switch (status) {
    CallStatusFilter.incoming => AppStrings.incomingCalls,
    CallStatusFilter.completed => AppStrings.completedCalls,
    CallStatusFilter.busy => AppStrings.busyCalls,
    CallStatusFilter.rejected => AppStrings.rejectedCalls,
    CallStatusFilter.notAnswered => AppStrings.notAnsweredCalls,
    CallStatusFilter.lowBalance => AppStrings.lowBalanceCalls,
    CallStatusFilter.missed => AppStrings.missedCalls,
  };

  static String _typeLabel(CallTypeOption type) => switch (type) {
    CallTypeOption.all => AppStrings.callsType,
    CallTypeOption.audio => AppStrings.audioCall,
    CallTypeOption.video => AppStrings.videoCall,
  };

  static String _periodLabel(CallPeriod period) => switch (period) {
    CallPeriod.day => AppStrings.day,
    CallPeriod.week => AppStrings.week,
    CallPeriod.month => AppStrings.month,
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CallsCubit>();
    final state = context.watch<CallsCubit>().state;

    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        spacing: _gap,
        runSpacing: _runGap,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: constraints.maxWidth < _searchWidth
                ? constraints.maxWidth
                : _searchWidth,
            child: AppSearchField(
              hint: AppStrings.searchUsersHint,
              onChanged: cubit.search,
            ),
          ),
          AppFilterDropdown<CallDateFilter>(
            value: state.date,
            options: CallDateFilter.values,
            labelOf: _dateLabel,
            onSelected: cubit.selectDate,
          ),
          AppFilterDropdown<CallStatusFilter>(
            value: state.status,
            options: CallStatusFilter.values,
            labelOf: _statusLabel,
            onSelected: cubit.selectStatus,
            width: _statusWidth,
          ),
          AppFilterDropdown<CallTypeOption>(
            value: state.type,
            options: CallTypeOption.values,
            labelOf: _typeLabel,
            onSelected: cubit.selectType,
            width: _typeWidth,
          ),
          AppFilterDropdown<CallPeriod>(
            value: state.period,
            options: CallPeriod.values,
            labelOf: _periodLabel,
            onSelected: cubit.selectPeriod,
            width: _periodWidth,
          ),
          TotalCallsCard(count: state.filteredCalls.length),
        ],
      ),
    );
  }
}
