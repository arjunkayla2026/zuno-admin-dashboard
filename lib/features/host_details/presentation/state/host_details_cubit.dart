import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/call_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/wallet_adjustment_type.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_wallet_adjustment_dialog.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/mock/host_details_mock_data.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/wallet_transaction.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_state.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';

class HostDetailsCubit extends Cubit<HostDetailsState> {
  HostDetailsCubit({
    required AdminHost host,
    this._onHostChanged,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(
         HostDetailsState(
           host: host,
           calls: HostDetailsMockData.calls,
           withdrawals: HostDetailsMockData.withdrawals,
           walletTransactions: HostDetailsMockData.walletTransactions,
           rangeStart: HostDetailsMockData.rangeStart,
           rangeEnd: HostDetailsMockData.rangeEnd,
           singleDate: HostDetailsMockData.rangeEnd,
           totalCredit: HostDetailsMockData.totalCreditFromAdmin,
           totalDebit: HostDetailsMockData.totalDebitFromAdmin,
         ),
       );

  final ValueChanged<AdminHost>? _onHostChanged;
  final DateTime Function() _clock;

  void updateHost(AdminHost host) {
    emit(state.copyWith(host: host));
    _onHostChanged?.call(host);
  }

  void adjustWallet(WalletAdjustment adjustment) {
    final host = state.host;
    final isCredit = adjustment.type == WalletAdjustmentType.credit;
    final now = _clock();
    final description = adjustment.description.isNotEmpty
        ? adjustment.description
        : isCredit
        ? AppStrings.adminCredit
        : AppStrings.adminDebit;
    final updated = host.copyWith(
      walletBalance: isCredit
          ? host.walletBalance + adjustment.amount
          : host.walletBalance - adjustment.amount,
    );
    emit(
      state.copyWith(
        host: updated,
        totalCredit: isCredit ? state.totalCredit + adjustment.amount : null,
        totalDebit: isCredit ? null : state.totalDebit + adjustment.amount,
        walletTransactions: [
          WalletTransaction(
            date: DateTime(now.year, now.month, now.day),
            type: adjustment.type,
            amount: adjustment.amount,
            description: description,
          ),
          ...state.walletTransactions,
        ],
      ),
    );
    _onHostChanged?.call(updated);
  }

  void selectTab(HostDetailsTab tab) => emit(state.copyWith(tab: tab));

  void selectWalletFilter(WalletFilter filter) =>
      emit(state.copyWith(walletFilter: filter));

  void selectType(CallTypeFilter filter) =>
      emit(state.copyWith(typeFilter: filter));

  void selectDateMode(CallDateMode mode) =>
      emit(state.copyWith(dateMode: mode));

  void setRangeStart(DateTime date) => emit(state.copyWith(rangeStart: date));

  void setRangeEnd(DateTime date) => emit(state.copyWith(rangeEnd: date));

  void setSingleDate(DateTime date) => emit(state.copyWith(singleDate: date));
}
