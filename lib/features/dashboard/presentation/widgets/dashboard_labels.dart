import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/features/dashboard/data/models/dashboard_stat.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/state/dashboard_state.dart';

abstract final class DashboardLabels {
  static const List<DateRangeFilter> filterOptions = [
    DateRangeFilter.today,
    DateRangeFilter.yesterday,
    DateRangeFilter.last7Days,
    DateRangeFilter.last30Days,
    DateRangeFilter.custom,
  ];

  static String filter(DateRangeFilter filter) => switch (filter) {
    DateRangeFilter.today => AppStrings.today,
    DateRangeFilter.yesterday => AppStrings.yesterday,
    DateRangeFilter.last7Days => AppStrings.last7Days,
    DateRangeFilter.last30Days => AppStrings.last30Days,
    DateRangeFilter.custom => AppStrings.customDateRange,
  };

  static String range(DashboardState state) {
    final custom = state.customRange;
    return switch (state.dateFilter) {
      DateRangeFilter.custom when custom != null => AppStrings.dateRangeLabel(
        DateFormatter.short(custom.start),
        DateFormatter.short(custom.end),
      ),
      final selected => filter(selected),
    };
  }

  static String _amount(double? value) => value == null
      ? AppStrings.emptyValue
      : NumberFormatter.rupeesAmount(value);

  static String _count(int? value) =>
      value == null ? AppStrings.emptyValue : NumberFormatter.grouped(value);

  static List<DashboardStat> revenue(DashboardState state) {
    final revenue = state.loadedRevenue;
    final calls = state.loadedCallRevenue;
    final messages = state.loadedMessageRevenue;
    final deletedProfit = state.loadedAccounts?.deletedWalletBalance;

    return [
      DashboardStat(
        label: AppStrings.topUpRevenue,
        value: _amount(revenue?.paidAmount),
      ),
      DashboardStat(
        label: AppStrings.hostAudioCallRevenue,
        value: _amount(calls?.hostAudio),
      ),
      DashboardStat(
        label: AppStrings.hostVideoCallRevenue,
        value: _amount(calls?.hostVideo),
      ),
      DashboardStat(
        label: AppStrings.adminCallRevenue,
        value: _amount(calls?.admin),
      ),
      DashboardStat(
        label: AppStrings.deletedAccountProfit,
        value: _amount(deletedProfit),
      ),
      DashboardStat(
        label: AppStrings.totalAdminRevenue,
        value: calls == null || messages == null || deletedProfit == null
            ? AppStrings.emptyValue
            : _amount(
                NumberFormatter.roundAmount(
                  calls.adminAudio +
                      calls.adminVideo +
                      messages +
                      deletedProfit,
                ),
              ),
      ),
    ];
  }

  static List<DashboardStat> users(DashboardState state) {
    final accounts = state.loadedAccounts;

    return [
      DashboardStat(
        label: AppStrings.totalUsers,
        value: _count(accounts?.activeUsers),
      ),
      DashboardStat(
        label: AppStrings.totalHosts,
        value: _count(accounts?.activeHosts),
      ),
      DashboardStat(
        label: AppStrings.deletedUsers,
        value: _count(accounts?.deletedUsers),
      ),
      DashboardStat(
        label: AppStrings.deletedHosts,
        value: _count(accounts?.deletedHosts),
      ),
      DashboardStat(
        label: AppStrings.freeBonusReceivedUsers,
        value: _count(accounts?.bonusUsers),
      ),
      DashboardStat(
        label: AppStrings.freeBonusAmount,
        value: _amount(accounts?.bonusAmount),
      ),
    ];
  }

  static List<DashboardStat> calls(DashboardState state) {
    final stats = state.loadedCallStats;

    return [
      DashboardStat(
        label: AppStrings.incomingCalls,
        value: _count(stats?.incoming),
      ),
      DashboardStat(
        label: AppStrings.answeredCalls,
        value: _count(stats?.answered),
      ),
      DashboardStat(
        label: AppStrings.rejectedCalls,
        value: _count(stats?.rejected),
      ),
      DashboardStat(
        label: AppStrings.missedCalls,
        value: _count(stats?.missed),
      ),
      DashboardStat(
        label: AppStrings.totalTalkingMinutes,
        value: _count(stats?.talkMinutes),
      ),
    ];
  }
}
