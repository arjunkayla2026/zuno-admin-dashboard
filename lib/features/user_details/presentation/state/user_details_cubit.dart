import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/enums/wallet_adjustment_type.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_wallet_adjustment_dialog.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/repositories/recharge_repository.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_state.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/repositories/user_management_repository.dart';

class UserDetailsCubit extends Cubit<UserDetailsState> {
  UserDetailsCubit(
    this._repository,
    this._users, {
    required AdminUser user,
    this._onUserChanged,
  }) : super(UserDetailsState(user: user));

  final RechargeRepository _repository;
  final UserManagementRepository _users;
  final ValueChanged<AdminUser>? _onUserChanged;

  /// Loads the transaction totals and re-reads the user document, since
  /// the [AdminUser] the page opened with is a snapshot from the user list
  /// and the wallet changes with every call, message and recharge.
  Future<void> loadRechargeSummary() async {
    final id = state.user.id;
    final (summaryResult, userResult) = await (
      _repository.fetchUserSummary(id),
      _users.fetchUser(id),
    ).wait;
    if (isClosed) return;
    userResult.match((_) {}, (fresh) {
      if (fresh == null) return;
      updateUser(
        state.user.copyWith(
          walletAmount: fresh.walletRupees,
          name: fresh.name,
          initials: fresh.initials,
          phone: fresh.phone,
          status: fresh.status,
        ),
      );
    });
    summaryResult.match(
      (_) => emit(state.copyWith(summaryStatus: LoadStatus.failure)),
      (summary) {
        if (state.user.recharges != summary.rechargeCount) {
          updateUser(state.user.copyWith(recharges: summary.rechargeCount));
        }
        emit(
          state.copyWith(
            totalRecharge: summary.totalRecharge,
            receivableTopUp: summary.receivableTopUp,
            adminCreditTotal: summary.adminCredit,
            adminDebitTotal: summary.adminDebit,
            summaryStatus: LoadStatus.loaded,
          ),
        );
      },
    );
  }

  Future<void> refresh() async {
    await Future.wait([loadRechargeSummary(), loadDeletedAccountProfit()]);
  }

  Future<void> loadDeletedAccountProfit() async {
    final result = await _users.fetchDeletedAccountProfit(state.user);
    if (isClosed) return;
    result.match(
      (_) => emit(state.copyWith(profitStatus: LoadStatus.failure)),
      (profit) => emit(
        state.copyWith(
          deletedAccountProfit: profit,
          profitStatus: LoadStatus.loaded,
        ),
      ),
    );
  }

  void updateUser(AdminUser user) {
    emit(state.copyWith(user: user));
    _onUserChanged?.call(user);
  }

  void applyWalletBalance(num walletBalance) {
    updateUser(state.user.copyWith(walletAmount: walletBalance.toDouble()));
  }

  void adjustWallet(WalletAdjustment adjustment) {
    final isCredit = adjustment.type == WalletAdjustmentType.credit;
    final amount = adjustment.amount;
    final current = state.user;
    final balance = current.walletRupees + (isCredit ? amount : -amount);
    final user = current.copyWith(
      walletAmount: NumberFormatter.roundAmount(balance),
      adminCredit: isCredit ? current.adminCredit + amount : null,
      adminDebit: isCredit ? null : current.adminDebit + amount,
    );
    emit(
      state.copyWith(
        user: user,
        adminCreditTotal: isCredit ? state.adminCreditTotal + amount : null,
        adminDebitTotal: isCredit ? null : state.adminDebitTotal + amount,
      ),
    );
    _onUserChanged?.call(user);
  }

  void selectTab(UserDetailsTab tab) => emit(state.copyWith(tab: tab));
}
