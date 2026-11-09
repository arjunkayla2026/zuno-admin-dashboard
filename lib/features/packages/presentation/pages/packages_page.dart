import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_shell.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/state/packages_cubit.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/state/packages_state.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/packages_content.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/mock/user_mock_data.dart';

class PackagesPage extends StatelessWidget {
  const PackagesPage({super.key});

  static AdminSubNavItem _subItem(PackagesTab tab) => switch (tab) {
    PackagesTab.packageList => AdminSubNavItem.packageList,
    PackagesTab.couponList => AdminSubNavItem.couponList,
  };

  static PackagesTab? _tabFor(AdminSubNavItem item) => switch (item) {
    AdminSubNavItem.packageList => PackagesTab.packageList,
    AdminSubNavItem.couponList => PackagesTab.couponList,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: BlocProvider(
        create: (_) => PackagesCubit(),
        child: BlocSelector<PackagesCubit, PackagesState, PackagesTab>(
          selector: (state) => state.tab,
          builder: (context, tab) => AdminShell(
            selectedItem: AdminNavItem.packages,
            selectedSubItem: _subItem(tab),
            onSubItemSelected: (item) {
              final selected = _tabFor(item);
              if (selected != null) {
                context.read<PackagesCubit>().selectTab(selected);
              }
            },
            title: AppStrings.packages,
            userName: UserMockData.adminName,
            userRole: UserMockData.adminRole,
            userInitials: UserMockData.adminInitials,
            child: const PackagesContent(),
          ),
        ),
      ),
    );
  }
}
