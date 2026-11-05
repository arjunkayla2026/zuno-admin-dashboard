import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_sidebar.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_top_bar.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.selectedItem,
    required this.userName,
    required this.userRole,
    required this.userInitials,
    required this.child,
    this.title,
    this.breadcrumb,
  });

  final AdminNavItem selectedItem;
  final String userName;
  final String userRole;
  final String userInitials;
  final Widget child;
  final String? title;
  final List<String>? breadcrumb;

  void _navigate(BuildContext context, AdminNavItem item) {
    final route = item.route;
    if (route == null || ModalRoute.of(context)?.settings.name == route) return;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final sidebar = AdminSidebar(
      selectedItem: selectedItem,
      userName: userName,
      userRole: userRole,
      onItemSelected: (item) => _navigate(context, item),
    );
    final isDesktop = AppUtils.isDesktop(context);

    return Scaffold(
      drawer: isDesktop
          ? null
          : Drawer(width: AdminSidebar.width, child: sidebar),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isDesktop) sidebar,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Builder(
                  builder: (context) => AdminTopBar(
                    userName: userName,
                    userRole: userRole,
                    userInitials: userInitials,
                    title: title,
                    breadcrumb: breadcrumb,
                    onMenuPressed: isDesktop
                        ? null
                        : () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
