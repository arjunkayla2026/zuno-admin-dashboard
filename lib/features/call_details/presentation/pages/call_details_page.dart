import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_shell.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_empty_state.dart';
import 'package:zuno_admin_dashboard/features/call_details/presentation/widgets/call_details_content.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/mock/user_mock_data.dart';

class CallDetailsPage extends StatelessWidget {
  const CallDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)?.settings.arguments;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: AdminShell(
        selectedItem: AdminNavItem.calls,
        title: AppStrings.callDetails,
        breadcrumb: const [AppStrings.calls, AppStrings.callDetails],
        userName: UserMockData.adminName,
        userRole: UserMockData.adminRole,
        userInitials: UserMockData.adminInitials,
        child: argument is CallLog
            ? CallDetailsContent(call: argument)
            : const AppEmptyState(
                icon: Icons.call_outlined,
                title: AppStrings.callDetails,
                message: AppStrings.callNotFound,
              ),
      ),
    );
  }
}
