import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/dashboard/data/models/dashboard_stat.dart';

abstract final class DashboardMockData {
  static const String adminName = 'Rakesh Menon';
  static const String adminRole = 'Super Admin';
  static const String adminInitials = 'RM';

  static const List<DashboardStat> todayCallRevenue = [
    DashboardStat(label: AppStrings.hostAudioCallRevenue, value: '₹6,240'),
    DashboardStat(label: AppStrings.hostVideoCallRevenue, value: '₹4,385'),
    DashboardStat(label: AppStrings.adminCallRevenue, value: '₹9,870'),
  ];

  static const List<DashboardStat> customCallRevenue = [
    DashboardStat(label: AppStrings.hostAudioCallRevenue, value: '₹82,992'),
    DashboardStat(label: AppStrings.hostVideoCallRevenue, value: '₹58,320'),
    DashboardStat(label: AppStrings.adminCallRevenue, value: '₹1,31,271'),
  ];

  static const List<DashboardStat> todayCalls = [
    DashboardStat(label: AppStrings.incomingCalls, value: '1,840'),
    DashboardStat(label: AppStrings.answeredCalls, value: '1,306'),
    DashboardStat(label: AppStrings.rejectedCalls, value: '202'),
    DashboardStat(label: AppStrings.missedCalls, value: '332'),
    DashboardStat(label: AppStrings.totalTalkingMinutes, value: '9,620'),
  ];

  static const List<DashboardStat> customCalls = [
    DashboardStat(label: AppStrings.incomingCalls, value: '24,472'),
    DashboardStat(label: AppStrings.answeredCalls, value: '17,375'),
    DashboardStat(label: AppStrings.rejectedCalls, value: '2,692'),
    DashboardStat(label: AppStrings.missedCalls, value: '4,405'),
    DashboardStat(label: AppStrings.totalTalkingMinutes, value: '1,27,946'),
  ];
}
