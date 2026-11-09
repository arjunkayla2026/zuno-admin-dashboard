import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/utils/date_range_matcher.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';

enum RechargeSourceFilter {
  all,
  adminRecharges,
  adminCreditDebit,
  gatewayPayments,
}

enum RechargeStatusFilter { all, completed, failed, created }

class RechargeState {
  const RechargeState({
    required this.transactions,
    required this.today,
    this.query = '',
    this.dateFilter = DateRangeFilter.all,
    this.customRange,
    this.sourceFilter = RechargeSourceFilter.all,
    this.statusFilter = RechargeStatusFilter.all,
    this.page = 1,
  });

  static const int pageSize = 11;

  final List<RechargeTransaction> transactions;
  final DateTime today;
  final String query;
  final DateRangeFilter dateFilter;
  final DateTimeRange? customRange;
  final RechargeSourceFilter sourceFilter;
  final RechargeStatusFilter statusFilter;
  final int page;

  bool _matchesSource(RechargeTransaction transaction) =>
      switch (sourceFilter) {
        RechargeSourceFilter.all => true,
        RechargeSourceFilter.adminRecharges => transaction.isAdminRecharge,
        RechargeSourceFilter.adminCreditDebit => transaction.isAdminAdjustment,
        RechargeSourceFilter.gatewayPayments => transaction.isGatewayPayment,
      };

  bool _matchesStatus(RechargeStatus status) => switch (statusFilter) {
    RechargeStatusFilter.all => true,
    RechargeStatusFilter.completed => status == RechargeStatus.completed,
    RechargeStatusFilter.failed => status == RechargeStatus.failed,
    RechargeStatusFilter.created => status == RechargeStatus.created,
  };

  bool _matchesQuery(RechargeTransaction transaction) {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return true;
    final digits = term.replaceAll(' ', '');
    return [
          transaction.userName,
          transaction.orderId,
          transaction.paymentId ?? '',
        ].any((text) => text.toLowerCase().contains(term)) ||
        (digits.isNotEmpty &&
            transaction.phone.replaceAll(' ', '').contains(digits));
  }

  List<RechargeTransaction> get filteredTransactions => transactions
      .where(
        (transaction) =>
            dateFilter.includes(
              transaction.dateTime,
              today: today,
              customRange: customRange,
            ) &&
            _matchesSource(transaction) &&
            _matchesStatus(transaction.status) &&
            _matchesQuery(transaction),
      )
      .toList();

  int _sumOf(RechargeKind kind) => filteredTransactions
      .where((transaction) => transaction.kind == kind)
      .fold(0, (sum, transaction) => sum + transaction.amount);

  int get rechargeCount => filteredTransactions
      .where((transaction) => transaction.kind == RechargeKind.recharge)
      .length;

  int get rechargeAmount => _sumOf(RechargeKind.recharge);

  int get creditAmount => _sumOf(RechargeKind.credit);

  int get debitAmount => _sumOf(RechargeKind.debit);

  int get totalPages {
    final count = filteredTransactions.length;
    if (count == 0) return 1;
    return (count / pageSize).ceil();
  }

  int get firstIndex => (page - 1) * pageSize;

  List<RechargeTransaction> get pageTransactions =>
      filteredTransactions.skip(firstIndex).take(pageSize).toList();

  RechargeState copyWith({
    String? query,
    DateRangeFilter? dateFilter,
    DateTimeRange? customRange,
    RechargeSourceFilter? sourceFilter,
    RechargeStatusFilter? statusFilter,
    int? page,
  }) {
    return RechargeState(
      transactions: transactions,
      today: today,
      query: query ?? this.query,
      dateFilter: dateFilter ?? this.dateFilter,
      customRange: customRange ?? this.customRange,
      sourceFilter: sourceFilter ?? this.sourceFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      page: page ?? this.page,
    );
  }
}
