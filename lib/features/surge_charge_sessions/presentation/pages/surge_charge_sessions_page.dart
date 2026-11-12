import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/di/injection_container.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_shell.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/state/surge_sessions_cubit.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/widgets/surge_sessions_content.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/mock/user_mock_data.dart';

class SurgeChargeSessionsPage extends StatelessWidget {
  const SurgeChargeSessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: BlocProvider(
        create: (_) => getIt<SurgeSessionsCubit>()..load(),
        child: const AdminShell(
          selectedItem: AdminNavItem.hostManagement,
          selectedSubItem: AdminSubNavItem.surgeChargeSessions,
          title: AppStrings.surgeChargeSessions,
          breadcrumb: [
            AppStrings.hostManagement,
            AppStrings.surgeChargeSessions,
          ],
          userName: UserMockData.adminName,
          userRole: UserMockData.adminRole,
          userInitials: UserMockData.adminInitials,
          child: SurgeSessionsContent(),
        ),
      ),
    );
  }
}
