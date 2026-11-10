import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';

enum RechargeSourceFilter {
  all(null),
  adminRecharges(RechargeTransaction.rechargeTypes),
  adminCreditDebit(RechargeTransaction.adjustmentTypes),
  gatewayPayments(RechargeTransaction.rechargeTypes);

  const RechargeSourceFilter(this.types);

  final List<String>? types;

  bool includes(RechargeTransaction transaction) => switch (this) {
    RechargeSourceFilter.all => true,
    RechargeSourceFilter.adminRecharges => transaction.isAdminRecharge,
    RechargeSourceFilter.adminCreditDebit => transaction.isAdminAdjustment,
    RechargeSourceFilter.gatewayPayments => transaction.isGatewayPayment,
  };
}

enum RechargeStatusFilter {
  all(null),
  completed(RechargeTransaction.completedStatuses),
  failed(RechargeTransaction.failedStatuses),
  created(RechargeTransaction.createdStatuses);

  const RechargeStatusFilter(this.statuses);

  final List<String>? statuses;

  bool includes(RechargeStatus status) => switch (this) {
    RechargeStatusFilter.all => true,
    RechargeStatusFilter.completed => status == RechargeStatus.completed,
    RechargeStatusFilter.failed => status == RechargeStatus.failed,
    RechargeStatusFilter.created => status == RechargeStatus.created,
  };
}

class RechargeState {
  const RechargeState({
    required this.today,
    this.transactions = const [],
    this.status = LoadStatus.loading,
    this.errorMessage,
    this.query = '',
    this.dateFilter = DateRangeFilter.all,
    this.customRange,
    this.sourceFilter = RechargeSourceFilter.all,
    this.statusFilter = RechargeStatusFilter.all,
    this.page = 1,
    this.totalPages = 1,
    this.firstIndex = 0,
    this.totals,
  });

  static final RegExp _amountPattern = RegExp(r'^\d+(\.\d{0,2})?$');
  static final RegExp _separators = RegExp(r'[\s,₹]');

  final List<RechargeTransaction> transactions;
  final LoadStatus status;
  final String? errorMessage;
  final DateTime today;
  final String query;
  final DateRangeFilter dateFilter;
  final DateTimeRange? customRange;
  final RechargeSourceFilter sourceFilter;
  final RechargeStatusFilter statusFilter;
  final int page;
  final int totalPages;
  final int firstIndex;
  final RechargeTotals? totals;

  bool get isSearching => query.trim().isNotEmpty;

  bool matchesFilters(RechargeTransaction transaction) =>
      sourceFilter.includes(transaction) &&
      statusFilter.includes(transaction.status);

  bool matchesSearch(RechargeTransaction transaction) =>
      matchesFilters(transaction) && _matchesQuery(transaction);

  bool _matchesQuery(RechargeTransaction transaction) {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return true;
    if (transaction.userName.toLowerCase().contains(term)) return true;
    if ([
      transaction.displayOrderId,
      transaction.paymentId ?? '',
    ].any((id) => id.toLowerCase().contains(term))) {
      return true;
    }

    final compact = term.replaceAll(_separators, '');
    if (compact.isEmpty) return false;
    if (transaction.phone.replaceAll(' ', '').contains(compact)) return true;
    return _amountPattern.hasMatch(compact) &&
        NumberFormatter.amountInput(transaction.amount).startsWith(compact);
  }

  RechargeState copyWith({
    List<RechargeTransaction>? transactions,
    LoadStatus? status,
    String? errorMessage,
    DateTime? today,
    String? query,
    DateRangeFilter? dateFilter,
    DateTimeRange? customRange,
    RechargeSourceFilter? sourceFilter,
    RechargeStatusFilter? statusFilter,
    int? page,
    int? totalPages,
    int? firstIndex,
    RechargeTotals? totals,
    bool clearTotals = false,
  }) {
    return RechargeState(
      transactions: transactions ?? this.transactions,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      today: today ?? this.today,
      query: query ?? this.query,
      dateFilter: dateFilter ?? this.dateFilter,
      customRange: customRange ?? this.customRange,
      sourceFilter: sourceFilter ?? this.sourceFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      firstIndex: firstIndex ?? this.firstIndex,
      totals: clearTotals ? null : totals ?? this.totals,
    );
  }
}
