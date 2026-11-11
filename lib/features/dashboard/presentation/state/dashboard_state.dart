import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/data/user_account_totals.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/utils/date_range_matcher.dart';
import 'package:zuno_admin_dashboard/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';

class DashboardState {
  const DashboardState({
    required this.today,
    this.dateFilter = DateRangeFilter.today,
    this.customRange,
    this.revenueStatus = LoadStatus.loading,
    this.revenue,
    this.revenueError,
    this.accountsStatus = LoadStatus.loading,
    this.accounts,
    this.accountsError,
    this.recentStatus = LoadStatus.loading,
    this.recentRecharges = const [],
    this.recentError,
  });

  final DateTime today;
  final DateRangeFilter dateFilter;
  final DateTimeRange? customRange;
  final LoadStatus revenueStatus;
  final RechargeRevenue? revenue;
  final String? revenueError;
  final LoadStatus accountsStatus;
  final UserAccountTotals? accounts;
  final String? accountsError;
  final LoadStatus recentStatus;
  final List<RechargeTransaction> recentRecharges;
  final String? recentError;

  DashboardRange get range =>
      dateFilter.momentBounds(today: today, customRange: customRange);

  RechargeRevenue? get loadedRevenue =>
      revenueStatus == LoadStatus.loaded ? revenue : null;

  UserAccountTotals? get loadedAccounts =>
      accountsStatus == LoadStatus.loaded ? accounts : null;

  DashboardState withRange({
    required DateTime today,
    required DateRangeFilter dateFilter,
    DateTimeRange? customRange,
  }) => DashboardState(
    today: today,
    dateFilter: dateFilter,
    customRange: customRange ?? this.customRange,
    revenueStatus: revenueStatus,
    revenue: revenue,
    revenueError: revenueError,
    accountsStatus: accountsStatus,
    accounts: accounts,
    accountsError: accountsError,
    recentStatus: recentStatus,
    recentRecharges: recentRecharges,
    recentError: recentError,
  );

  DashboardState copyWith({
    LoadStatus? revenueStatus,
    RechargeRevenue? revenue,
    String? revenueError,
    LoadStatus? accountsStatus,
    UserAccountTotals? accounts,
    String? accountsError,
    LoadStatus? recentStatus,
    List<RechargeTransaction>? recentRecharges,
    String? recentError,
  }) {
    return DashboardState(
      today: today,
      dateFilter: dateFilter,
      customRange: customRange,
      revenueStatus: revenueStatus ?? this.revenueStatus,
      revenue: revenue ?? this.revenue,
      revenueError: revenueError ?? this.revenueError,
      accountsStatus: accountsStatus ?? this.accountsStatus,
      accounts: accounts ?? this.accounts,
      accountsError: accountsError ?? this.accountsError,
      recentStatus: recentStatus ?? this.recentStatus,
      recentRecharges: recentRecharges ?? this.recentRecharges,
      recentError: recentError ?? this.recentError,
    );
  }
}
