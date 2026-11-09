import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/di/injection_container.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_shell.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_cubit.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_state.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/approval_content.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/mock/user_mock_data.dart';

class ApprovalPage extends StatelessWidget {
  const ApprovalPage({super.key});

  static AdminSubNavItem _subItem(ApprovalTab tab) => switch (tab) {
    ApprovalTab.hostRequests => AdminSubNavItem.hostRequests,
    ApprovalTab.payoutReview => AdminSubNavItem.payoutReview,
    ApprovalTab.profilePhotoReview => AdminSubNavItem.profilePhotoReview,
  };

  static ApprovalTab? _tabFor(AdminSubNavItem item) => switch (item) {
    AdminSubNavItem.hostRequests => ApprovalTab.hostRequests,
    AdminSubNavItem.payoutReview => ApprovalTab.payoutReview,
    AdminSubNavItem.profilePhotoReview => ApprovalTab.profilePhotoReview,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: BlocProvider(
        create: (_) => getIt<ApprovalCubit>()..loadHostRequests(),
        child: BlocSelector<ApprovalCubit, ApprovalState, ApprovalTab>(
          selector: (state) => state.tab,
          builder: (context, tab) => AdminShell(
            selectedItem: AdminNavItem.approval,
            selectedSubItem: _subItem(tab),
            onSubItemSelected: (item) {
              final selected = _tabFor(item);
              if (selected != null) {
                context.read<ApprovalCubit>().selectTab(selected);
              }
            },
            title: AppStrings.approval,
            userName: UserMockData.adminName,
            userRole: UserMockData.adminRole,
            userInitials: UserMockData.adminInitials,
            child: const ApprovalContent(),
          ),
        ),
      ),
    );
  }
}
