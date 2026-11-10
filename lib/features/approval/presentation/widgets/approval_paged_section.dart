import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_footer.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_cubit.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_pager.dart';

class ApprovalPagedSection extends StatelessWidget {
  const ApprovalPagedSection({
    super.key,
    required this.paging,
    required this.shownCount,
    required this.child,
  });

  final ApprovalPaging paging;
  final int shownCount;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        child,
        const Divider(color: AppColors.cardBorder),
        AppTableFooter(
          firstIndex: paging.firstIndex,
          shownCount: shownCount,
          totalCount: paging.total,
          currentPage: paging.page,
          totalPages: paging.totalPages,
          onPageChanged: context.read<ApprovalCubit>().goToPage,
        ),
      ],
    );
  }
}
