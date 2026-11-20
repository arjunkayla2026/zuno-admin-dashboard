import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/core/data/payout_settings.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_sheet_row.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_summary.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

enum PaymentTab {
  withdrawalList(WithdrawalStatus.open),
  pending(WithdrawalStatus.pending),
  success(WithdrawalStatus.success),
  failed(WithdrawalStatus.failed);

  const PaymentTab(this.status);

  final WithdrawalStatus status;

  bool get isSelectable => this != PaymentTab.success;
}

/// The rows loaded for one sheet export: [candidates] payouts were
/// considered, [rows] could be exported, and [wholeTab] is true when nothing
/// was selected, so every payout of [tab] was used.
typedef PayoutSheetLoad = ({
  PaymentTab tab,
  bool wholeTab,
  int candidates,
  List<PayoutSheetRow> rows,
});

class PaymentState {
  /// Tabs whose payouts can be exported as a bank withdrawal sheet.
  static const List<PaymentTab> exportTabs = [
    PaymentTab.withdrawalList,
    PaymentTab.pending,
  ];

  const PaymentState({
    this.tab = PaymentTab.withdrawalList,
    this.query = '',
    this.withdrawals = const [],
    this.status = LoadStatus.loading,
    this.errorMessage,
    this.page = 1,
    this.totalPages = 1,
    this.firstIndex = 0,
    this.minimumPayout,
    this.minimumLoaded = false,
    this.summary,
    this.openNetTotal,
    this.pendingCount,
    this.paidCount,
    this.failedCount,
    this.searchCount,
    this.selected = const {},
    this.selectingAll = false,
    this.exporting = false,
    this.batchRunning = false,
    this.successDateFilter = DateRangeFilter.today,
    this.successCustomRange,
    this.beneficiaryExportedIds = const {},
    this.beneficiaryExportedTabs = const {},
  });

  static const int tdsPercent = PayoutSettings.tdsPercent;

  static const List<DateRangeFilter> successDateOptions = [
    DateRangeFilter.all,
    DateRangeFilter.today,
    DateRangeFilter.last7Days,
    DateRangeFilter.last30Days,
    DateRangeFilter.custom,
  ];

  final PaymentTab tab;
  final String query;
  final List<Withdrawal> withdrawals;
  final LoadStatus status;
  final String? errorMessage;
  final int page;
  final int totalPages;
  final int firstIndex;
  final double? minimumPayout;
  final bool minimumLoaded;
  final PayoutSummary? summary;

  /// The Withdrawal List rows' amounts after each one's TDS
  /// ([Withdrawal.netAfterPanTds]), shown as Total Withdraw.
  final double? openNetTotal;
  final int? pendingCount;
  final int? paidCount;
  final int? failedCount;
  final int? searchCount;
  final Map<String, Withdrawal> selected;
  final bool selectingAll;
  final bool exporting;
  final bool batchRunning;
  final DateRangeFilter successDateFilter;
  final DateTimeRange? successCustomRange;

  /// Payouts whose host was in a beneficiary sheet exported on this page.
  final Set<String> beneficiaryExportedIds;

  /// Tabs whose whole beneficiary sheet (nothing selected) was exported since
  /// the last refresh, with no unregistered payout added to them since.
  final Set<PaymentTab> beneficiaryExportedTabs;

  /// The withdrawal sheet is offered only after the beneficiary sheet for the
  /// same payouts: the selected ones, or the whole tab when none is selected.
  bool get canExportWithdrawals => selected.isEmpty
      ? beneficiaryExportedTabs.contains(tab)
      : selected.keys.every(beneficiaryExportedIds.contains);

  bool get isSearching => query.trim().isNotEmpty;

  int get readyCount => summary?.hostCount ?? 0;

  double get readyEarned => summary?.amountEarned ?? 0;

  int get readyMinutes => summary?.callMinutes ?? 0;

  double get readyCredit => summary?.hostCredit ?? 0;

  double get readyRevenue => summary?.hostRevenue ?? 0;

  double get readyTotal => summary?.totalAmount ?? 0;

  double get readyNetTotal => openNetTotal ?? 0;

  int? countOf(PaymentTab tab) => switch (tab) {
    PaymentTab.withdrawalList => summary?.hostCount,
    PaymentTab.pending => pendingCount,
    PaymentTab.success => paidCount,
    PaymentTab.failed => failedCount,
  };

  int? get totalCount => isSearching ? searchCount : countOf(tab);

  bool canSelect(Withdrawal withdrawal) =>
      tab.isSelectable &&
      withdrawal.status == tab.status &&
      withdrawal.hasBankAccount;

  bool isSelected(Withdrawal withdrawal) => selected.containsKey(withdrawal.id);

  List<Withdrawal> get selectableRows => withdrawals.where(canSelect).toList();

  bool? get pageSelection {
    final rows = selectableRows;
    final selectedRows = rows.where(isSelected).length;
    if (selectedRows == 0) return false;
    return selectedRows == rows.length ? true : null;
  }

  List<Withdrawal> get selectedPending =>
      selected.values.where((item) => item.isPending).toList();

  double get selectedTotal =>
      selected.values.fold(0, (total, item) => total + item.totalAmount);

  double get selectedTds => selected.values.fold(
    0,
    (total, item) => total + item.tdsAmount(tdsPercent),
  );

  bool get canSelectMore {
    final total = totalCount;
    return total != null && selected.length < total;
  }

  PaymentState withView(CursorPageView<Withdrawal> view) => copyWith(
    withdrawals: view.items,
    status: view.status,
    errorMessage: view.error,
    page: view.page,
    totalPages: view.totalPages,
    firstIndex: view.firstIndex,
  );

  PaymentState copyWith({
    PaymentTab? tab,
    String? query,
    List<Withdrawal>? withdrawals,
    LoadStatus? status,
    String? errorMessage,
    int? page,
    int? totalPages,
    int? firstIndex,
    double? minimumPayout,
    bool? minimumLoaded,
    PayoutSummary? summary,
    double? openNetTotal,
    int? pendingCount,
    int? paidCount,
    bool clearPaidCount = false,
    int? failedCount,
    int? searchCount,
    bool clearSearchCount = false,
    Map<String, Withdrawal>? selected,
    bool? selectingAll,
    bool? exporting,
    bool? batchRunning,
    DateRangeFilter? successDateFilter,
    DateTimeRange? successCustomRange,
    Set<String>? beneficiaryExportedIds,
    Set<PaymentTab>? beneficiaryExportedTabs,
  }) {
    return PaymentState(
      tab: tab ?? this.tab,
      query: query ?? this.query,
      withdrawals: withdrawals ?? this.withdrawals,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      firstIndex: firstIndex ?? this.firstIndex,
      minimumPayout: minimumPayout ?? this.minimumPayout,
      minimumLoaded: minimumLoaded ?? this.minimumLoaded,
      summary: summary ?? this.summary,
      openNetTotal: openNetTotal ?? this.openNetTotal,
      pendingCount: pendingCount ?? this.pendingCount,
      paidCount: clearPaidCount ? null : paidCount ?? this.paidCount,
      failedCount: failedCount ?? this.failedCount,
      searchCount: clearSearchCount ? null : searchCount ?? this.searchCount,
      selected: selected ?? this.selected,
      selectingAll: selectingAll ?? this.selectingAll,
      exporting: exporting ?? this.exporting,
      batchRunning: batchRunning ?? this.batchRunning,
      successDateFilter: successDateFilter ?? this.successDateFilter,
      successCustomRange: successCustomRange ?? this.successCustomRange,
      beneficiaryExportedIds:
          beneficiaryExportedIds ?? this.beneficiaryExportedIds,
      beneficiaryExportedTabs:
          beneficiaryExportedTabs ?? this.beneficiaryExportedTabs,
    );
  }
}
