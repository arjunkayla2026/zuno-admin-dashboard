import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_shell.dart';
import 'package:zuno_admin_dashboard/features/dashboard/data/mock/dashboard_mock_data.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/state/dashboard_cubit.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/widgets/dashboard_content.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: BlocProvider(
        create: (_) => DashboardCubit(),
        child: const AdminShell(
          selectedItem: AdminNavItem.dashboard,
          userName: DashboardMockData.adminName,
          userRole: DashboardMockData.adminRole,
          userInitials: DashboardMockData.adminInitials,
          child: DashboardContent(),
        ),
      ),
    );
  }
}
