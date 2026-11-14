import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/core/data/payout_settings.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_summary.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

enum PaymentTab { withdrawalList, pending, success }

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
    this.paidCount,
    this.searchCount,
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
  final int? paidCount;
  final int? searchCount;

  bool get isSearching => query.trim().isNotEmpty;

  int get pendingCount => summary?.hostCount ?? 0;

  double get pendingEarned => summary?.amountEarned ?? 0;

  int get pendingMinutes => summary?.callMinutes ?? 0;

  double get pendingCredit => summary?.hostCredit ?? 0;

  double get pendingTotal => summary?.totalAmount ?? 0;

  int? countOf(PaymentTab tab) {
    final pending = summary?.hostCount;
    final paid = paidCount;
    return switch (tab) {
      PaymentTab.withdrawalList =>
        pending == null || paid == null ? null : pending + paid,
      PaymentTab.pending => pending,
      PaymentTab.success => paid,
    };
  }

  int? get totalCount => isSearching ? searchCount : countOf(tab);

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
    int? paidCount,
    int? searchCount,
    bool clearSearchCount = false,
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
      paidCount: paidCount ?? this.paidCount,
      searchCount: clearSearchCount ? null : searchCount ?? this.searchCount,
    );
  }
}
