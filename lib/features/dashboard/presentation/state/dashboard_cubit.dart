import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/features/dashboard/data/mock/dashboard_mock_data.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/state/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit()
    : super(
        DashboardState(
          rangeType: DashboardRangeType.today,
          customStart: DashboardMockData.customRangeStart,
          customEnd: DashboardMockData.customRangeEnd,
          stats: DashboardMockData.today,
          recentRecharges: DashboardMockData.recentRecharges,
        ),
      );

  void selectRangeType(DashboardRangeType rangeType) {
    emit(
      state.copyWith(
        rangeType: rangeType,
        stats: rangeType == DashboardRangeType.today
            ? DashboardMockData.today
            : DashboardMockData.customRange,
      ),
    );
  }

  void setCustomStart(DateTime date) => emit(state.copyWith(customStart: date));

  void setCustomEnd(DateTime date) => emit(state.copyWith(customEnd: date));
}
