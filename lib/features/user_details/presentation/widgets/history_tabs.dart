import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_underline_tabs.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_state.dart';

class HistoryTabs extends StatelessWidget {
  const HistoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
      builder: (context, state) {
        return AppUnderlineTabs<UserDetailsTab>(
          tabs: const {
            UserDetailsTab.calls: AppStrings.callHistory,
            UserDetailsTab.recharges: AppStrings.rechargeHistory,
          },
          counts: {UserDetailsTab.calls: state.calls.length},
          value: state.tab,
          onChanged: context.read<UserDetailsCubit>().selectTab,
        );
      },
    );
  }
}
