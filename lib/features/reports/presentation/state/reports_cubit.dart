import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/features/reports/data/mock/reports_mock_data.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/state/reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit()
    : super(
        ReportsState(
          reports: ReportsMockData.reports,
          today: ReportsMockData.today,
        ),
      );

  void search(String query) => emit(state.copyWith(query: query, page: 1));

  void selectDateFilter(DateRangeFilter filter) =>
      emit(state.copyWith(dateFilter: filter, page: 1));

  void selectCustomRange(DateTimeRange range) => emit(
    state.copyWith(
      dateFilter: DateRangeFilter.custom,
      customRange: range,
      page: 1,
    ),
  );

  void selectType(ReportTypeFilter filter) =>
      emit(state.copyWith(typeFilter: filter, page: 1));

  void selectReporter(ReporterFilter filter) =>
      emit(state.copyWith(reporterFilter: filter, page: 1));

  void goToPage(int page) => emit(state.copyWith(page: page));
}
