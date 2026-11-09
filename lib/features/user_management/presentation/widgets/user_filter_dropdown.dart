import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_filter_dropdown.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_management_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_management_state.dart';

class UserFilterDropdown extends StatelessWidget {
  const UserFilterDropdown({super.key});

  static String _label(UserFilter filter) => switch (filter) {
    UserFilter.all => AppStrings.allUsers,
    UserFilter.newUsers => AppStrings.newUsers,
    UserFilter.blocked => AppStrings.blockedUsers,
    UserFilter.deletedByAdmin => AppStrings.deletedByAdminFilter,
    UserFilter.deletedByUser => AppStrings.deletedByUserFilter,
  };

  @override
  Widget build(BuildContext context) {
    final filter = context.select(
      (UserManagementCubit cubit) => cubit.state.filter,
    );

    return AppFilterDropdown<UserFilter>(
      value: filter,
      options: UserFilter.values,
      labelOf: _label,
      onSelected: context.read<UserManagementCubit>().selectFilter,
    );
  }
}
