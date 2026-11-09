import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_empty_state.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_underline_tabs.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/state/packages_cubit.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/state/packages_state.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/package_list_summary.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/packages_table.dart';

class PackagesTabsCard extends StatelessWidget {
  const PackagesTabsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PackagesCubit, PackagesState>(
      builder: (context, state) {
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
              AppUnderlineTabs<PackagesTab>(
                tabs: const {
                  PackagesTab.packageList: AppStrings.packageList,
                  PackagesTab.couponList: AppStrings.couponList,
                },
                counts: {PackagesTab.packageList: state.packages.length},
                value: state.tab,
                onChanged: context.read<PackagesCubit>().selectTab,
              ),
              const Divider(color: AppColors.cardBorder),
              ...switch (state.tab) {
                PackagesTab.packageList => [
                  PackageListSummary(
                    packageCount: state.packages.length,
                    totalRecharges: state.totalRecharges,
                  ),
                  PackagesTable(packages: state.packages),
                ],
                PackagesTab.couponList => const [
                  AppEmptyState(
                    icon: Icons.description_outlined,
                    title: AppStrings.couponListPendingTitle,
                    message: AppStrings.couponListPendingMessage,
                  ),
                ],
              },
            ],
          ),
        );
      },
    );
  }
}
