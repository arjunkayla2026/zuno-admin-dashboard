import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_wallet_adjustment_dialog.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/wallet_transaction.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/repositories/host_earnings_repository.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_state.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class HostDetailsCubit extends Cubit<HostDetailsState> {
  HostDetailsCubit(
    this._repository, {
    required AdminHost host,
    this._onHostChanged,
  }) : super(HostDetailsState(host: host));

  final HostEarningsRepository _repository;
  final ValueChanged<AdminHost>? _onHostChanged;
  bool _withdrawalsOpened = false;
  bool _walletOpened = false;

  late final CursorPager<Withdrawal> _withdrawalPager = CursorPager(
    fetch: (cursor) =>
        _repository.fetchWithdrawals(state.host.hostId, cursor: cursor),
    onChanged: (view) {
      if (!isClosed) emit(state.copyWith(withdrawals: view));
    },
  );

  late final CursorPager<WalletTransaction> _walletPager = CursorPager(
    fetch: (cursor) => _repository.fetchWallet(
      state.host.hostId,
      type: state.walletType,
      cursor: cursor,
    ),
    onChanged: (view) {
      if (!isClosed) emit(state.copyWith(wallet: view));
    },
  );

  Future<void> load() => _loadSummary();

  void updateHost(AdminHost host) {
    emit(state.copyWith(host: host));
    _onHostChanged?.call(host);
  }

  void selectTab(HostDetailsTab tab) {
    emit(state.copyWith(tab: tab));
    switch (tab) {
      case HostDetailsTab.withdrawals:
        _withdrawalsOpened = true;
        unawaited(_withdrawalPager.load());
      case HostDetailsTab.wallet:
        _walletOpened = true;
        unawaited(_walletPager.load());
      case HostDetailsTab.calls:
        break;
    }
  }

  void selectWalletFilter(WalletFilter filter) {
    if (filter == state.walletFilter) return;
    emit(state.copyWith(walletFilter: filter));
    if (_walletOpened) unawaited(_walletPager.reset());
  }

  void goToWithdrawalPage(int page) => _withdrawalPager.goToPage(page);

  void goToWalletPage(int page) => _walletPager.goToPage(page);

  Future<void> retryWithdrawals() => _withdrawalPager.load();

  Future<void> retryWallet() => _walletPager.load();

  Future<String?> adjustWallet(WalletAdjustment adjustment) async {
    emit(state.copyWith(adjusting: true));
    final result = await _repository.adjust(
      state.host.hostId,
      type: adjustment.type,
      amount: adjustment.amount,
      description: adjustment.description,
    );
    if (isClosed) return null;
    emit(state.copyWith(adjusting: false));

    return result.match((failure) => failure.message, (_) {
      unawaited(_loadSummary());
      if (_walletOpened) unawaited(_walletPager.reset());
      if (_withdrawalsOpened) unawaited(_withdrawalPager.reset());
      return null;
    });
  }

  Future<void> _loadSummary() async {
    final hostId = state.host.hostId;
    final (totals, count) = await (
      _repository.fetchTotals(hostId),
      _repository.countWithdrawals(hostId),
    ).wait;
    if (isClosed) return;
    emit(
      state.copyWith(
        totals: totals.toNullable(),
        withdrawalCount: count.toNullable(),
      ),
    );
  }
}
