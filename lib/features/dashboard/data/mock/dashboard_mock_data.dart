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
}
