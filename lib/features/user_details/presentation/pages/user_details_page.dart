import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/di/injection_container.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_shell.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/add_recharge_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_recharge_history_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/user_details_content.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/mock/user_mock_data.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_actions_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_details_arguments.dart';

class UserDetailsPage extends StatelessWidget {
  const UserDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.arguments;
    final arguments = route is UserDetailsArguments
        ? route
        : UserDetailsArguments(user: UserMockData.users.first);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                getIt<UserDetailsCubit>(param1: arguments)
                  ..loadRechargeSummary(),
          ),
          BlocProvider(create: (_) => getIt<UserActionsCubit>()),
          BlocProvider(create: (_) => getIt<AddRechargeCubit>()),
          BlocProvider(
            create: (_) =>
                getIt<UserRechargeHistoryCubit>(param1: arguments.user.id)
                  ..load(),
          ),
        ],
        child: const AdminShell(
          selectedItem: AdminNavItem.userManagement,
          title: AppStrings.userDetails,
          breadcrumb: [AppStrings.userManagement, AppStrings.userDetails],
          userName: UserMockData.adminName,
          userRole: UserMockData.adminRole,
          userInitials: UserMockData.adminInitials,
          child: UserDetailsContent(),
        ),
      ),
    );
  }
}
