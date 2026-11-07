import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/mock/recharge_mock_data.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/state/recharge_state.dart';

class RechargeCubit extends Cubit<RechargeState> {
  RechargeCubit()
    : super(
        RechargeState(
          transactions: RechargeMockData.transactions,
          today: RechargeMockData.today,
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

  void selectSource(RechargeSourceFilter filter) =>
      emit(state.copyWith(sourceFilter: filter, page: 1));

  void selectStatus(RechargeStatusFilter filter) =>
      emit(state.copyWith(statusFilter: filter, page: 1));

  void goToPage(int page) => emit(state.copyWith(page: page));
}
