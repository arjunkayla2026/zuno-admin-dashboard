import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_search_field.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_cubit.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/approval_filter_button.dart';

class ApprovalToolbar extends StatelessWidget {
  const ApprovalToolbar({super.key});

  static const double _searchWidth = 478;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _searchWidth),
            child: AppSearchField(
              hint: AppStrings.searchUsersHint,
              onChanged: context.read<ApprovalCubit>().search,
            ),
          ),
        ),
        const SizedBox(width: AppUtils.spacingXs),
        const ApprovalFilterButton(),
      ],
    );
  }
}
