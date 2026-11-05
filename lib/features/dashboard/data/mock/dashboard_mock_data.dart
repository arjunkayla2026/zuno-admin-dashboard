import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/dashboard/data/models/dashboard_stat.dart';
import 'package:zuno_admin_dashboard/features/dashboard/data/models/dashboard_stats.dart';
import 'package:zuno_admin_dashboard/features/dashboard/data/models/recharge_activity.dart';

abstract final class DashboardMockData {
  static const String adminName = 'Rakesh Menon';
  static const String adminRole = 'Super Admin';
  static const String adminInitials = 'RM';

  static final DateTime customRangeStart = DateTime(2026, 10, 22);
  static final DateTime customRangeEnd = DateTime(2026, 11, 4);

  static const DashboardStats today = DashboardStats(
    revenue: [
      DashboardStat(label: AppStrings.topUpRevenue, value: '₹18,460'),
      DashboardStat(label: AppStrings.hostAudioCallRevenue, value: '₹6,240'),
      DashboardStat(label: AppStrings.hostVideoCallRevenue, value: '₹4,385'),
      DashboardStat(label: AppStrings.adminCallRevenue, value: '₹9,870'),
      DashboardStat(label: AppStrings.deletedAccountProfit, value: '₹640'),
      DashboardStat(label: AppStrings.totalAdminRevenue, value: '₹10,510'),
    ],
    users: [
      DashboardStat(label: AppStrings.totalUsers, value: '12,480'),
      DashboardStat(label: AppStrings.totalHosts, value: '1,126'),
      DashboardStat(label: AppStrings.deletedUsers, value: '38'),
      DashboardStat(label: AppStrings.deletedHosts, value: '3'),
      DashboardStat(label: AppStrings.freeBonusReceivedUsers, value: '214'),
      DashboardStat(label: AppStrings.freeBonusAmount, value: '₹21,400'),
    ],
    calls: [
      DashboardStat(label: AppStrings.incomingCalls, value: '1,840'),
      DashboardStat(label: AppStrings.answeredCalls, value: '1,306'),
      DashboardStat(label: AppStrings.rejectedCalls, value: '202'),
      DashboardStat(label: AppStrings.missedCalls, value: '332'),
      DashboardStat(label: AppStrings.totalTalkingMinutes, value: '9,620'),
    ],
  );

  static const DashboardStats customRange = DashboardStats(
    revenue: [
      DashboardStat(label: AppStrings.topUpRevenue, value: '₹2,45,518'),
      DashboardStat(label: AppStrings.hostAudioCallRevenue, value: '₹82,992'),
      DashboardStat(label: AppStrings.hostVideoCallRevenue, value: '₹58,320'),
      DashboardStat(label: AppStrings.adminCallRevenue, value: '₹1,31,271'),
      DashboardStat(label: AppStrings.deletedAccountProfit, value: '₹8,512'),
      DashboardStat(label: AppStrings.totalAdminRevenue, value: '₹1,39,783'),
    ],
    users: [
      DashboardStat(label: AppStrings.totalUsers, value: '12,480'),
      DashboardStat(label: AppStrings.totalHosts, value: '1,126'),
      DashboardStat(label: AppStrings.deletedUsers, value: '505'),
      DashboardStat(label: AppStrings.deletedHosts, value: '40'),
      DashboardStat(label: AppStrings.freeBonusReceivedUsers, value: '2,846'),
      DashboardStat(label: AppStrings.freeBonusAmount, value: '₹2,84,600'),
    ],
    calls: [
      DashboardStat(label: AppStrings.incomingCalls, value: '24,472'),
      DashboardStat(label: AppStrings.answeredCalls, value: '17,375'),
      DashboardStat(label: AppStrings.rejectedCalls, value: '2,692'),
      DashboardStat(label: AppStrings.missedCalls, value: '4,405'),
      DashboardStat(label: AppStrings.totalTalkingMinutes, value: '1,27,946'),
    ],
  );

  static const List<RechargeActivity> recentRecharges = [
    RechargeActivity(
      userName: 'Deepak Shetty',
      userInitials: 'DS',
      userId: 'ZU10247',
      amount: '₹449',
      time: '04 Nov 2026, 06:33 PM',
    ),
    RechargeActivity(
      userName: 'Salman Faris',
      userInitials: 'SF',
      userId: 'ZU10258',
      amount: '₹199',
      time: '04 Nov 2026, 03:29 PM',
    ),
    RechargeActivity(
      userName: 'Vishnu Das',
      userInitials: 'VD',
      userId: 'ZU10233',
      amount: '₹99',
      time: '04 Nov 2026, 03:19 PM',
    ),
    RechargeActivity(
      userName: 'Harish V',
      userInitials: 'HV',
      userId: 'ZU10246',
      amount: '₹99',
      time: '04 Nov 2026, 03:19 PM',
    ),
    RechargeActivity(
      userName: 'Deepak Shetty',
      userInitials: 'DS',
      userId: 'ZU10247',
      amount: '₹199',
      time: '04 Nov 2026, 01:59 PM',
    ),
  ];
}
