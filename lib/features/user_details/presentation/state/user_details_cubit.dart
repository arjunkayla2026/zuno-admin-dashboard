import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/call_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/enums/wallet_adjustment_type.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_wallet_adjustment_dialog.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/repositories/recharge_repository.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/mock/user_details_mock_data.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_state.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

class UserDetailsCubit extends Cubit<UserDetailsState> {
  UserDetailsCubit(
    this._repository, {
    required AdminUser user,
    this._onUserChanged,
  }) : super(
         UserDetailsState(
           user: user,
           calls: UserDetailsMockData.calls,
           rangeStart: UserDetailsMockData.rangeStart,
           rangeEnd: UserDetailsMockData.rangeEnd,
           singleDate: UserDetailsMockData.rangeEnd,
         ),
       );

  final RechargeRepository _repository;
  final ValueChanged<AdminUser>? _onUserChanged;

  Future<void> loadRechargeSummary() async {
    final result = await _repository.fetchUserSummary(state.user.id);
    if (isClosed) return;
    result.match(
      (_) => emit(state.copyWith(summaryStatus: LoadStatus.failure)),
      (summary) => emit(
        state.copyWith(
          totalRecharge: summary.totalRecharge,
          availableCoins: summary.receivedCoins,
          summaryStatus: LoadStatus.loaded,
        ),
      ),
    );
  }

  void updateUser(AdminUser user) {
    emit(state.copyWith(user: user));
    _onUserChanged?.call(user);
  }

  void applyWalletBalance(num walletBalance) {
    updateUser(
      state.user.copyWith(
        walletBalance: NumberFormatter.grouped(walletBalance.truncate()),
      ),
    );
  }

  void adjustWallet(WalletAdjustment adjustment) {
    final isCredit = adjustment.type == WalletAdjustmentType.credit;
    final amount = adjustment.amount;
    final current = state.user;
    final balance = state.walletBalance + (isCredit ? amount : -amount);
    final coins = PackagePlan.coinsFor(amount.toDouble());
    final user = current.copyWith(
      walletBalance: NumberFormatter.grouped(balance),
      adminCredit: isCredit ? current.adminCredit + amount : null,
      adminDebit: isCredit ? null : current.adminDebit + amount,
    );
    emit(
      state.copyWith(
        user: user,
        availableCoins: state.availableCoins + (isCredit ? coins : -coins),
      ),
    );
    _onUserChanged?.call(user);
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
