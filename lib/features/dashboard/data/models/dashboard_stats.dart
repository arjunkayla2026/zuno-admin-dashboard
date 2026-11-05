import 'package:zuno_admin_dashboard/features/dashboard/data/models/dashboard_stat.dart';

class DashboardStats {
  const DashboardStats({
    required this.revenue,
    required this.users,
    required this.calls,
  });

  final List<DashboardStat> revenue;
  final List<DashboardStat> users;
  final List<DashboardStat> calls;
}
