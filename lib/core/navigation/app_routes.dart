import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/pages/approval_page.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/pages/admin_login_page.dart';
import 'package:zuno_admin_dashboard/features/call_details/presentation/pages/call_details_page.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/pages/calls_page.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/pages/host_details_page.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/pages/host_management_page.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/pages/packages_page.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/pages/recharge_page.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/pages/reports_page.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/pages/surge_charge_sessions_page.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/pages/user_details_page.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/pages/user_management_page.dart';

abstract final class AppRoutes {
  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String userManagement = '/users';
  static const String userDetails = '/users/details';
  static const String hostManagement = '/hosts';
  static const String hostDetails = '/hosts/details';
  static const String surgeChargeSessions = '/hosts/surge-sessions';
  static const String calls = '/calls';
  static const String callDetails = '/calls/details';
  static const String approval = '/approval';
  static const String reports = '/reports';
  static const String packages = '/packages';
  static const String recharge = '/recharge';

  static final Map<String, WidgetBuilder> routes = {
    login: (_) => const AdminLoginPage(),
    dashboard: (_) => const DashboardPage(),
    userManagement: (_) => const UserManagementPage(),
    userDetails: (_) => const UserDetailsPage(),
    hostManagement: (_) => const HostManagementPage(),
    hostDetails: (_) => const HostDetailsPage(),
    surgeChargeSessions: (_) => const SurgeChargeSessionsPage(),
    calls: (_) => const CallsPage(),
    callDetails: (_) => const CallDetailsPage(),
    approval: (_) => const ApprovalPage(),
    reports: (_) => const ReportsPage(),
    packages: (_) => const PackagesPage(),
    recharge: (_) => const RechargePage(),
  };
}
