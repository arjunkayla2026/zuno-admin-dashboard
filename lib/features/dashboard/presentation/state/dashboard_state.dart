import 'package:zuno_admin_dashboard/features/dashboard/data/models/dashboard_stats.dart';
import 'package:zuno_admin_dashboard/features/dashboard/data/models/recharge_activity.dart';

enum DashboardRangeType { today, custom }

class DashboardState {
  const DashboardState({
    required this.rangeType,
    required this.customStart,
    required this.customEnd,
    required this.stats,
    required this.recentRecharges,
  });

  final DashboardRangeType rangeType;
  final DateTime customStart;
  final DateTime customEnd;
  final DashboardStats stats;
  final List<RechargeActivity> recentRecharges;

  bool get isCustomRange => rangeType == DashboardRangeType.custom;

  DashboardState copyWith({
    DashboardRangeType? rangeType,
    DateTime? customStart,
    DateTime? customEnd,
    DashboardStats? stats,
  }) {
    return DashboardState(
      rangeType: rangeType ?? this.rangeType,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
      stats: stats ?? this.stats,
      recentRecharges: recentRecharges,
    );
  }
}
