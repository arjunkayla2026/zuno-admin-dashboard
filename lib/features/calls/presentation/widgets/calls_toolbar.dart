import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_date_filter_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_filter_dropdown.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_search_field.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/calls_cubit.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/calls_state.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/widgets/call_log_labels.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/widgets/total_calls_card.dart';

class CallsToolbar extends StatelessWidget {
  const CallsToolbar({super.key});

  static const double _searchWidth = 480;
  static const double _gap = 4;
  static const double _runGap = 8;
  static const double _statusWidth = 220;
  static const double _typeWidth = 208;

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
              hint: AppStrings.searchCallsHint,
              onChanged: cubit.search,
            ),
          ),
          AppDateFilterButton(
            value: state.dateFilter,
            today: state.today,
            customRange: state.customRange,
            options: CallsState.dateOptions,
            onFilterSelected: cubit.selectDateFilter,
            onCustomRangeSelected: cubit.selectCustomRange,
          ),
          AppFilterDropdown<CallStatusFilter>(
            value: state.statusFilter,
            options: CallStatusFilter.values,
            labelOf: CallLogLabels.statusFilter,
            onSelected: cubit.selectStatus,
            width: _statusWidth,
          ),
          AppFilterDropdown<CallTypeOption>(
            value: state.typeFilter,
            options: CallTypeOption.values,
            labelOf: CallLogLabels.typeFilter,
            onSelected: cubit.selectType,
            width: _typeWidth,
          ),
          TotalCallsCard(count: state.shownCount),
        ],
      ),
    );
  }
}
