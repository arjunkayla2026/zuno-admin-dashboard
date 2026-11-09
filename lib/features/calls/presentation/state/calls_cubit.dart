import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/features/calls/data/mock/calls_mock_data.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/calls_state.dart';

class CallsCubit extends Cubit<CallsState> {
  CallsCubit()
    : super(CallsState(calls: CallsMockData.calls, today: CallsMockData.today));

  void search(String query) => emit(state.copyWith(query: query, page: 1));

  void selectDate(CallDateFilter date) =>
      emit(state.copyWith(date: date, page: 1));

  void selectPeriod(CallPeriod period) =>
      emit(state.copyWith(period: period, page: 1));

  void selectStatus(CallStatusFilter status) =>
      emit(state.copyWith(status: status, page: 1));

  void selectType(CallTypeOption type) =>
      emit(state.copyWith(type: type, page: 1));

  void goToPage(int page) => emit(state.copyWith(page: page));
}
