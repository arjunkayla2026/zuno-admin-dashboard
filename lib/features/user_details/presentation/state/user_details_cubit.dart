import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/call_filter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/mock/user_details_mock_data.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/models/recharge_package.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_state.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

class UserDetailsCubit extends Cubit<UserDetailsState> {
  UserDetailsCubit({required AdminUser user, this._onUserChanged})
    : super(
        UserDetailsState(
          user: user,
          totalRecharge: UserDetailsMockData.totalRecharge,
          availableCoins: NumberFormatter.parse(user.walletBalance),
          calls: UserDetailsMockData.calls,
          rangeStart: UserDetailsMockData.rangeStart,
          rangeEnd: UserDetailsMockData.rangeEnd,
          singleDate: UserDetailsMockData.rangeEnd,
        ),
      );

  final ValueChanged<AdminUser>? _onUserChanged;

  void updateUser(AdminUser user) {
    emit(state.copyWith(user: user));
    _onUserChanged?.call(user);
  }

  void addRecharge(RechargePackage package) {
    emit(
      state.copyWith(
        totalRecharge: state.totalRecharge + package.price,
        availableCoins: state.availableCoins + package.totalCoins,
      ),
    );
  }

  void selectTab(UserDetailsTab tab) => emit(state.copyWith(tab: tab));

  void selectType(CallTypeFilter filter) =>
      emit(state.copyWith(typeFilter: filter));

  void selectDateMode(CallDateMode mode) =>
      emit(state.copyWith(dateMode: mode));

  void setRangeStart(DateTime date) => emit(state.copyWith(rangeStart: date));

  void setRangeEnd(DateTime date) => emit(state.copyWith(rangeEnd: date));

  void setSingleDate(DateTime date) => emit(state.copyWith(singleDate: date));
}
