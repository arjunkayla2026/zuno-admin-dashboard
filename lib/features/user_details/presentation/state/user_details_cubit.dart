import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/call_filter.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/mock/user_details_mock_data.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/models/recharge_package.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/models/recharge_record.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_state.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

class UserDetailsCubit extends Cubit<UserDetailsState> {
  UserDetailsCubit({
    required AdminUser user,
    this._onUserChanged,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(
         UserDetailsState(
           user: user,
           totalRecharge: UserDetailsMockData.totalRecharge,
           availableCoins: NumberFormatter.parse(user.walletBalance),
           calls: UserDetailsMockData.calls,
           recharges: UserDetailsMockData.recharges,
           rangeStart: UserDetailsMockData.rangeStart,
           rangeEnd: UserDetailsMockData.rangeEnd,
           singleDate: UserDetailsMockData.rangeEnd,
         ),
       );

  static const String _orderPrefix = 'ADM-';
  static const String _orderAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const int _orderLength = 8;

  final ValueChanged<AdminUser>? _onUserChanged;
  final DateTime Function() _clock;
  final Random _random = Random();

  String _newOrderId() {
    final suffix = List.generate(
      _orderLength,
      (_) => _orderAlphabet[_random.nextInt(_orderAlphabet.length)],
    ).join();
    return '$_orderPrefix$suffix';
  }

  void updateUser(AdminUser user) {
    emit(state.copyWith(user: user));
    _onUserChanged?.call(user);
  }

  void addRecharge(RechargePackage package) {
    final now = _clock();
    final record = RechargeRecord(
      date: DateTime(now.year, now.month, now.day),
      time: DateFormatter.time(now),
      type: AppStrings.adminRecharge,
      amount: NumberFormatter.rupees(package.price),
      receivedCoins: NumberFormatter.grouped(package.totalCoins),
      orderId: _newOrderId(),
    );
    emit(
      state.copyWith(
        recharges: [record, ...state.recharges],
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

  void searchRecharges(String query) =>
      emit(state.copyWith(rechargeQuery: query));
}
