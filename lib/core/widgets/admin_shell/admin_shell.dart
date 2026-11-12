import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/data/admin_account.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_content_transition.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_sidebar.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_top_bar.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/admin_session_cubit.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.selectedItem,
    required this.userName,
    required this.userRole,
    required this.userInitials,
    required this.child,
    this.selectedSubItem,
    this.title,
    this.breadcrumb,
    this.onSubItemSelected,
    this.topBarNotice,
  });

  final AdminNavItem selectedItem;
  final ValueChanged<AdminSubNavItem>? onSubItemSelected;
  final AdminSubNavItem? selectedSubItem;
  final String userName;
  final String userRole;
  final String userInitials;
  final Widget child;
  final String? title;
  final List<String>? breadcrumb;
  final Widget? topBarNotice;

  void _navigate(BuildContext context, String? route) {
    if (route == null || ModalRoute.of(context)?.settings.name == route) return;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final account = context.select<AdminSessionCubit, AdminAccount?>(
      (cubit) => cubit.state.account,
    );
    final name = account?.name ?? userName;
    final role = account?.role.label ?? userRole;
    final initials = account?.initials ?? userInitials;
    final isDesktop = AppUtils.isDesktop(context);
    final sidebar = AdminSidebar(
      items: account?.accessibleModules ?? AdminNavItem.values,
      selectedItem: selectedItem,
      selectedSubItem: selectedSubItem,
      userName: name,
      userRole: role,
      animateSelectionChange: isDesktop,
      onItemSelected: (item) => _navigate(context, item.route),
      onSubItemSelected:
          onSubItemSelected ?? (item) => _navigate(context, item.route),
    );

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
                    userName: name,
                    userRole: role,
                    userInitials: initials,
                    title: title,
                    breadcrumb: breadcrumb,
                    notice: topBarNotice,
                    onMenuPressed: isDesktop
                        ? null
                        : () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                Expanded(
                  child: AdminContentTransition(
                    transitionKey: selectedSubItem,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
