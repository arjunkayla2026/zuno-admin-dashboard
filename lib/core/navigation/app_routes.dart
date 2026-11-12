import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_page_route.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/pages/approval_page.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/pages/admin_login_page.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/widgets/admin_access_gate.dart';
import 'package:zuno_admin_dashboard/features/call_details/presentation/pages/call_details_page.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/pages/calls_page.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/pages/host_details_page.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/pages/host_management_page.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/pages/packages_page.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/pages/payment_page.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/pages/settings_page.dart';
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
  static const String payment = '/payment';
  static const String settings = '/settings';

  static final RouteObserver<PageRoute<dynamic>> observer =
      RouteObserver<PageRoute<dynamic>>();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder == null) return null;
    return AppPageRoute<dynamic>(
      builder: builder,
      settings: settings,
      fadeIn: settings.name == login,
    );
  }

  static final Map<String, WidgetBuilder> routes = {
    login: (_) => const AdminLoginPage(),
    dashboard: _gated(AdminNavItem.dashboard, const DashboardPage()),
    userManagement: _gated(
      AdminNavItem.userManagement,
      const UserManagementPage(),
    ),
    userDetails: _gated(AdminNavItem.userManagement, const UserDetailsPage()),
    hostManagement: _gated(
      AdminNavItem.hostManagement,
      const HostManagementPage(),
    ),
    hostDetails: _gated(AdminNavItem.hostManagement, const HostDetailsPage()),
    surgeChargeSessions: _gated(
      AdminNavItem.hostManagement,
      const SurgeChargeSessionsPage(),
    ),
    calls: _gated(AdminNavItem.calls, const CallsPage()),
    callDetails: _gated(AdminNavItem.calls, const CallDetailsPage()),
    approval: _gated(AdminNavItem.approval, const ApprovalPage()),
    reports: _gated(AdminNavItem.reports, const ReportsPage()),
    packages: _gated(AdminNavItem.packages, const PackagesPage()),
    recharge: _gated(AdminNavItem.recharge, const RechargePage()),
    payment: _gated(AdminNavItem.payment, const PaymentPage()),
    settings: _gated(AdminNavItem.settings, const SettingsPage()),
  };

  static WidgetBuilder _gated(AdminNavItem module, Widget page) =>
      (_) => AdminAccessGate(module: module, child: page);
}
