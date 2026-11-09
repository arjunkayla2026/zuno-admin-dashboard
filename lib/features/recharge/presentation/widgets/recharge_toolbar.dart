import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_date_filter_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_filter_dropdown.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_search_field.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/state/recharge_cubit.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/state/recharge_state.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/widgets/recharge_labels.dart';

class RechargeToolbar extends StatelessWidget {
  const RechargeToolbar({super.key});

  static const double _searchWidth = 478;
  static const double _sourceWidth = 236;
  static const double _sourceMenuWidth = 210;
  static const double _statusWidth = 130;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RechargeCubit>();
    final state = context.watch<RechargeCubit>().state;

    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        spacing: AppUtils.spacingXs,
        runSpacing: AppUtils.spacingSm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: constraints.maxWidth < _searchWidth
                ? constraints.maxWidth
                : _searchWidth,
            child: AppSearchField(
              hint: AppStrings.searchRechargeTransactionsHint,
              onChanged: cubit.search,
            ),
          ),
          AppDateFilterButton(
            value: state.dateFilter,
            today: state.today,
            customRange: state.customRange,
            onFilterSelected: cubit.selectDateFilter,
            onCustomRangeSelected: cubit.selectCustomRange,
          ),
          AppFilterDropdown<RechargeSourceFilter>(
            value: state.sourceFilter,
            options: RechargeSourceFilter.values,
            labelOf: RechargeLabels.sourceFilter,
            onSelected: cubit.selectSource,
            width: _sourceWidth,
            menuWidth: _sourceMenuWidth,
          ),
          AppFilterDropdown<RechargeStatusFilter>(
            value: state.statusFilter,
            options: RechargeStatusFilter.values,
            labelOf: RechargeLabels.statusFilter,
            onSelected: cubit.selectStatus,
            width: _statusWidth,
          ),
        ],
      ),
    );
  }
}
