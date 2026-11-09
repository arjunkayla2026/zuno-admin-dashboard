import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';

enum RechargeSourceFilter {
  all,
  adminRecharges,
  adminCreditDebit,
  gatewayPayments,
}

enum RechargeStatusFilter { all, completed, failed, created }

class RechargeState {
  RechargeState({
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
  });

  static const int pageSize = 11;
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

  late final List<RechargeTransaction> filteredTransactions = transactions
      .where(
        (transaction) =>
            _matchesSource(transaction) &&
            _matchesStatus(transaction.status) &&
            _matchesQuery(transaction),
      )
      .toList();

  late final List<RechargeTransaction> _completed = filteredTransactions
      .where((transaction) => transaction.isCompleted)
      .toList();

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

  double _sumOf(RechargeKind kind) => _completed
      .where((transaction) => transaction.kind == kind)
      .fold(0, (sum, transaction) => sum + transaction.amount);

  int get rechargeCount => _completed
      .where((transaction) => transaction.kind == RechargeKind.recharge)
      .length;

  double get rechargeAmount => _sumOf(RechargeKind.recharge);

  double get creditAmount => _sumOf(RechargeKind.credit);

  double get debitAmount => _sumOf(RechargeKind.debit);

  int get totalPages {
    final count = filteredTransactions.length;
    if (count == 0) return 1;
    return (count / pageSize).ceil();
  }

  int get firstIndex => (page - 1) * pageSize;

  List<RechargeTransaction> get pageTransactions =>
      filteredTransactions.skip(firstIndex).take(pageSize).toList();

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
    );
  }
}
