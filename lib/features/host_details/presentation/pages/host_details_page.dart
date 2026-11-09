import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_shell.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_details_content.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/mock/host_mock_data.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_details_arguments.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/mock/user_mock_data.dart';

class HostDetailsPage extends StatelessWidget {
  const HostDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.arguments;
    final arguments = route is HostDetailsArguments
        ? route
        : HostDetailsArguments(host: HostMockData.hosts.first);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: BlocProvider(
        create: (_) => HostDetailsCubit(
          host: arguments.host,
          onHostChanged: arguments.onHostChanged,
        ),
        child: const AdminShell(
          selectedItem: AdminNavItem.hostManagement,
          selectedSubItem: AdminSubNavItem.hostList,
          title: AppStrings.hostDetails,
          breadcrumb: [AppStrings.hostManagement, AppStrings.hostDetails],
          userName: UserMockData.adminName,
          userRole: UserMockData.adminRole,
          userInitials: UserMockData.adminInitials,
          child: HostDetailsContent(),
        ),
      ),
    );
  }
}
