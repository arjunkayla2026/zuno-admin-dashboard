import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/core/enums/wallet_adjustment_type.dart';
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

  Future<void> refresh() async {
    if (state.adjusting) return;
    await Future.wait([
      _loadSummary(),
      if (_withdrawalsOpened) _withdrawalPager.reset(),
      if (_walletOpened) _walletPager.reset(),
    ]);
  }

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
      _showAdjustment(adjustment);
      unawaited(_loadSummary());
      if (_walletOpened) unawaited(_walletPager.reset());
      if (_withdrawalsOpened) unawaited(_withdrawalPager.reset());
      return null;
    });
  }

  /// Loads the cards' totals and re-reads the host, whose
  /// `hostDetails.hostEarnings` (Total Revenue, Available Wallet Amount)
  /// grows with every settled call, so the copy the page opened with from
  /// the host list goes stale. Runs when the page opens and after every credit / debit. A
  /// failed load clears the totals (the cards show "—") instead of
  /// silently keeping figures from before the change.
  Future<void> _loadSummary() async {
    final hostId = state.host.hostId;
    final (totals, count, host) = await (
      _repository.fetchTotals(hostId),
      _repository.countWithdrawals(hostId),
      _repository.fetchHost(hostId),
    ).wait;
    if (isClosed) return;
    host.match((_) {}, (fresh) {
      if (fresh != null) updateHost(fresh);
    });
    emit(
      state.copyWith(
        totals: totals.toNullable(),
        clearTotals: totals.isLeft(),
        withdrawalCount: count.toNullable(),
      ),
    );
    await _loadLedgerAdjustments();
  }

  /// The credit / debit cards add up the host's `host_admin_credit` /
  /// `host_admin_debit` ledger entries every time. Every adjustment ever
  /// made has one, so the totals are always complete, whether or not the
  /// `hostEarnings` totals have been backfilled (a stored total created by
  /// the first adjustment after the backend update would only hold the
  /// adjustments since then).
  Future<void> _loadLedgerAdjustments() async {
    final result = await _repository.fetchLedgerAdjustments(state.host.hostId);
    if (isClosed) return;
    // A failed reload keeps the figures already shown (including a credit or
    // debit just made); the error is logged by the data source.
    result.match(
      (_) {},
      (adjustments) => emit(state.copyWith(ledgerAdjustments: adjustments)),
    );
  }

  /// Shows a credit / debit the backend has just accepted in the totals
  /// straight away; the ledger reload that follows confirms it.
  void _showAdjustment(WalletAdjustment adjustment) {
    final amount = adjustment.amount.toDouble();
    final isCredit = adjustment.type == WalletAdjustmentType.credit;
    final current = state.ledgerAdjustments;
    if (current == null) return;
    emit(
      state.copyWith(
        ledgerAdjustments: isCredit
            ? current.plus(credit: amount)
            : current.plus(debit: amount),
      ),
    );
  }
}
