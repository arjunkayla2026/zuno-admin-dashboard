import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/pages/admin_login_page.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/pages/user_details_page.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/pages/user_management_page.dart';

abstract final class AppRoutes {
  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String userManagement = '/users';
  static const String userDetails = '/users/details';

  static final Map<String, WidgetBuilder> routes = {
    login: (_) => const AdminLoginPage(),
    dashboard: (_) => const DashboardPage(),
    userManagement: (_) => const UserManagementPage(),
    userDetails: (_) => const UserDetailsPage(),
  };
}
