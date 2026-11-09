import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_date_filter_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_filter_dropdown.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_search_field.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/state/reports_cubit.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/state/reports_state.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/widgets/report_labels.dart';

class ReportsToolbar extends StatelessWidget {
  const ReportsToolbar({super.key});

  static const double _searchWidth = 478;
  static const double _dropdownWidth = 228;

  static String _reporterLabel(ReporterFilter filter) => switch (filter) {
    ReporterFilter.all => AppStrings.all,
    ReporterFilter.user => AppStrings.userRole,
    ReporterFilter.host => AppStrings.hostRole,
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportsCubit>();
    final state = context.watch<ReportsCubit>().state;

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
              hint: AppStrings.searchUsersHint,
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
          AppFilterDropdown<ReportTypeFilter>(
            value: state.typeFilter,
            options: ReportTypeFilter.values,
            labelOf: ReportLabels.typeFilter,
            onSelected: cubit.selectType,
            width: _dropdownWidth,
          ),
          AppFilterDropdown<ReporterFilter>(
            value: state.reporterFilter,
            options: ReporterFilter.values,
            labelOf: _reporterLabel,
            onSelected: cubit.selectReporter,
            width: _dropdownWidth,
          ),
        ],
      ),
    );
  }
}
