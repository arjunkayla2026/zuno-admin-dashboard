import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/core/data/payout_settings.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_summary.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

enum PaymentTab {
  withdrawalList(WithdrawalStatus.open),
  pending(WithdrawalStatus.pending),
  success(WithdrawalStatus.success);

  const PaymentTab(this.status);

  final WithdrawalStatus status;

  bool get isSelectable => this != PaymentTab.success;
}

class PaymentState {
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
    this.pendingCount,
    this.paidCount,
    this.searchCount,
    this.selected = const {},
    this.selectingAll = false,
    this.batchRunning = false,
  });

  static const int tdsPercent = PayoutSettings.tdsPercent;

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
  final int? pendingCount;
  final int? paidCount;
  final int? searchCount;
  final Map<String, Withdrawal> selected;
  final bool selectingAll;
  final bool batchRunning;

  bool get isSearching => query.trim().isNotEmpty;

  int get readyCount => summary?.hostCount ?? 0;

  double get readyEarned => summary?.amountEarned ?? 0;

  int get readyMinutes => summary?.callMinutes ?? 0;

  double get readyCredit => summary?.hostCredit ?? 0;

  double get readyTotal => summary?.totalAmount ?? 0;

  int? countOf(PaymentTab tab) => switch (tab) {
    PaymentTab.withdrawalList => summary?.hostCount,
    PaymentTab.pending => pendingCount,
    PaymentTab.success => paidCount,
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
    int? pendingCount,
    int? paidCount,
    int? searchCount,
    bool clearSearchCount = false,
    Map<String, Withdrawal>? selected,
    bool? selectingAll,
    bool? batchRunning,
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
      pendingCount: pendingCount ?? this.pendingCount,
      paidCount: paidCount ?? this.paidCount,
      searchCount: clearSearchCount ? null : searchCount ?? this.searchCount,
      selected: selected ?? this.selected,
      selectingAll: selectingAll ?? this.selectingAll,
      batchRunning: batchRunning ?? this.batchRunning,
    );
  }
}
