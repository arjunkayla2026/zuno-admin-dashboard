import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_filter_dropdown.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_management_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_management_state.dart';

class HostFilterDropdown extends StatelessWidget {
  const HostFilterDropdown({super.key});

  static String _label(HostFilter filter) => switch (filter) {
    HostFilter.today => AppStrings.today,
    HostFilter.all => AppStrings.allHosts,
    HostFilter.newHosts => AppStrings.newHosts,
    HostFilter.blocked => AppStrings.blockedHosts,
    HostFilter.deletedByAdmin => AppStrings.deletedByAdmin,
    HostFilter.deletedByUser => AppStrings.deletedByHost,
  };

  @override
  Widget build(BuildContext context) {
    final filter = context.select(
      (HostManagementCubit cubit) => cubit.state.filter,
    );

    return AppFilterDropdown<HostFilter>(
      value: filter,
      options: HostFilter.values,
      labelOf: _label,
      onSelected: context.read<HostManagementCubit>().selectFilter,
    );
  }
}
