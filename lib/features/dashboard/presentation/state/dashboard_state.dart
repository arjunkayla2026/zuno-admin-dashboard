import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/data/user_account_totals.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/utils/date_range_matcher.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_revenue.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_statistics.dart';
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
    this.callRevenueStatus = LoadStatus.loading,
    this.callRevenue,
    this.callRevenueError,
    this.messageRevenueStatus = LoadStatus.loading,
    this.messageRevenue,
    this.messageRevenueError,
    this.accountsStatus = LoadStatus.loading,
    this.accounts,
    this.accountsError,
    this.recentStatus = LoadStatus.loading,
    this.recentRecharges = const [],
    this.recentError,
    this.callsStatus = LoadStatus.loading,
    this.callStats,
    this.callsError,
  });

  final DateTime today;
  final DateRangeFilter dateFilter;
  final DateTimeRange? customRange;
  final LoadStatus revenueStatus;
  final RechargeRevenue? revenue;
  final String? revenueError;
  final LoadStatus callRevenueStatus;
  final CallRevenue? callRevenue;
  final String? callRevenueError;
  final LoadStatus messageRevenueStatus;

  /// Rupees charged for user-to-host chat messages, all kept by the admin.
  final double? messageRevenue;
  final String? messageRevenueError;
  final LoadStatus accountsStatus;
  final UserAccountTotals? accounts;
  final String? accountsError;
  final LoadStatus recentStatus;
  final List<RechargeTransaction> recentRecharges;
  final String? recentError;
  final LoadStatus callsStatus;
  final CallStatistics? callStats;
  final String? callsError;

  DashboardRange get range =>
      dateFilter.momentBounds(today: today, customRange: customRange);

  RechargeRevenue? get loadedRevenue =>
      revenueStatus == LoadStatus.loaded ? revenue : null;

  CallRevenue? get loadedCallRevenue =>
      callRevenueStatus == LoadStatus.loaded ? callRevenue : null;

  double? get loadedMessageRevenue =>
      messageRevenueStatus == LoadStatus.loaded ? messageRevenue : null;

  /// First failure among the loads that feed the revenue summary.
  String? get revenueSectionError => revenueStatus == LoadStatus.failure
      ? revenueError
      : callRevenueStatus == LoadStatus.failure
      ? callRevenueError
      : messageRevenueStatus == LoadStatus.failure
      ? messageRevenueError
      : null;

  UserAccountTotals? get loadedAccounts =>
      accountsStatus == LoadStatus.loaded ? accounts : null;

  CallStatistics? get loadedCallStats =>
      callsStatus == LoadStatus.loaded ? callStats : null;

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
    callRevenueStatus: callRevenueStatus,
    callRevenue: callRevenue,
    callRevenueError: callRevenueError,
    messageRevenueStatus: messageRevenueStatus,
    messageRevenue: messageRevenue,
    messageRevenueError: messageRevenueError,
    accountsStatus: accountsStatus,
    accounts: accounts,
    accountsError: accountsError,
    recentStatus: recentStatus,
    recentRecharges: recentRecharges,
    recentError: recentError,
    callsStatus: callsStatus,
    callStats: callStats,
    callsError: callsError,
  );

  DashboardState copyWith({
    LoadStatus? revenueStatus,
    RechargeRevenue? revenue,
    String? revenueError,
    LoadStatus? callRevenueStatus,
    CallRevenue? callRevenue,
    String? callRevenueError,
    LoadStatus? messageRevenueStatus,
    double? messageRevenue,
    String? messageRevenueError,
    LoadStatus? accountsStatus,
    UserAccountTotals? accounts,
    String? accountsError,
    LoadStatus? recentStatus,
    List<RechargeTransaction>? recentRecharges,
    String? recentError,
    LoadStatus? callsStatus,
    CallStatistics? callStats,
    String? callsError,
  }) {
    return DashboardState(
      today: today,
      dateFilter: dateFilter,
      customRange: customRange,
      revenueStatus: revenueStatus ?? this.revenueStatus,
      revenue: revenue ?? this.revenue,
      revenueError: revenueError ?? this.revenueError,
      callRevenueStatus: callRevenueStatus ?? this.callRevenueStatus,
      callRevenue: callRevenue ?? this.callRevenue,
      callRevenueError: callRevenueError ?? this.callRevenueError,
      messageRevenueStatus: messageRevenueStatus ?? this.messageRevenueStatus,
      messageRevenue: messageRevenue ?? this.messageRevenue,
      messageRevenueError: messageRevenueError ?? this.messageRevenueError,
      accountsStatus: accountsStatus ?? this.accountsStatus,
      accounts: accounts ?? this.accounts,
      accountsError: accountsError ?? this.accountsError,
      recentStatus: recentStatus ?? this.recentStatus,
      recentRecharges: recentRecharges ?? this.recentRecharges,
      recentError: recentError ?? this.recentError,
      callsStatus: callsStatus ?? this.callsStatus,
      callStats: callStats ?? this.callStats,
      callsError: callsError ?? this.callsError,
    );
  }
}
