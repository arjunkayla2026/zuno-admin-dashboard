import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/di/injection_container.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_shell.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/call_pricing_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_actions_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_management_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/host_management_content.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/mock/user_mock_data.dart';

class HostManagementPage extends StatelessWidget {
  const HostManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => getIt<HostManagementCubit>()..loadHosts(),
          ),
          BlocProvider(create: (_) => getIt<HostActionsCubit>()),
          BlocProvider(create: (_) => getIt<CallPricingCubit>()..load()),
        ],
        child: const AdminShell(
          selectedItem: AdminNavItem.hostManagement,
          selectedSubItem: AdminSubNavItem.hostList,
          title: AppStrings.hostManagement,
          userName: UserMockData.adminName,
          userRole: UserMockData.adminRole,
          userInitials: UserMockData.adminInitials,
          child: HostManagementContent(),
        ),
      ),
    );
  }
}
