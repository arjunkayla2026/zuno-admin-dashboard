import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_shell.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/calls_cubit.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/widgets/calls_content.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/mock/user_mock_data.dart';

class CallsPage extends StatelessWidget {
  const CallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: BlocProvider(
        create: (_) => CallsCubit(),
        child: const AdminShell(
          selectedItem: AdminNavItem.calls,
          title: AppStrings.calls,
          userName: UserMockData.adminName,
          userRole: UserMockData.adminRole,
          userInitials: UserMockData.adminInitials,
          child: CallsContent(),
        ),
      ),
    );
  }
}
