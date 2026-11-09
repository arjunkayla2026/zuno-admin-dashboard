import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_underline_tabs.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_cubit.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_state.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/host_requests_table.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/payout_requests_table.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/profile_photo_grid.dart';

class ApprovalTabsCard extends StatelessWidget {
  const ApprovalTabsCard({super.key});

  static const double _emptyHeight = 160;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApprovalCubit, ApprovalState>(
      builder: (context, state) {
        final requests = state.filteredHostRequests;
        final payouts = state.filteredPayoutRequests;
        final photos = state.filteredProfilePhotoRequests;

        Widget empty(String message) => SizedBox(
          height: _emptyHeight,
          child: Center(
            child: Text(
              message,
              style: AppTextStyles.tableCell.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
          ),
        );

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppUnderlineTabs<ApprovalTab>(
                tabs: const {
                  ApprovalTab.hostRequests: AppStrings.hostRequests,
                  ApprovalTab.payoutReview: AppStrings.payoutReview,
                  ApprovalTab.profilePhotoReview: AppStrings.profilePhotoReview,
                },
                counts: {
                  ApprovalTab.hostRequests: state.pendingCount,
                  ApprovalTab.payoutReview: state.pendingPayoutCount,
                  ApprovalTab.profilePhotoReview: state.pendingPhotoCount,
                },
                value: state.tab,
                onChanged: context.read<ApprovalCubit>().selectTab,
              ),
              const Divider(color: AppColors.cardBorder),
              switch (state.tab) {
                ApprovalTab.hostRequests when requests.isEmpty => empty(
                  AppStrings.noHostRequests,
                ),
                ApprovalTab.hostRequests => HostRequestsTable(
                  requests: requests,
                ),
                ApprovalTab.payoutReview when payouts.isEmpty => empty(
                  AppStrings.noPayoutRequests,
                ),
                ApprovalTab.payoutReview => PayoutRequestsTable(
                  payouts: payouts,
                ),
                ApprovalTab.profilePhotoReview when photos.isEmpty => empty(
                  AppStrings.noProfilePhotos,
                ),
                ApprovalTab.profilePhotoReview => ProfilePhotoGrid(
                  photos: photos,
                ),
              },
            ],
          ),
        );
      },
    );
  }
}
