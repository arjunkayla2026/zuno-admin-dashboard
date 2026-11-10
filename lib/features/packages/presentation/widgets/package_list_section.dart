import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_empty_state.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_footer.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/state/packages_cubit.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/state/packages_state.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/package_list_summary.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/packages_table.dart';

class PackageListSection extends StatelessWidget {
  const PackageListSection({super.key, required this.state});

  final PackagesState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PackageListSummary(
          packageCount: state.totalCount,
          activeCount: state.activeCount,
        ),
        switch (state.status) {
          LoadStatus.loading => const AppTableLoadingState(),
          LoadStatus.failure => AppTableErrorState(
            message: state.errorMessage ?? AppStrings.recordsLoadFailed,
            onRetry: context.read<PackagesCubit>().loadPackages,
          ),
          LoadStatus.loaded when state.packages.isEmpty => const AppEmptyState(
            icon: Icons.inventory_2_outlined,
            title: AppStrings.noPackages,
            message: AppStrings.noPackagesMessage,
          ),
          LoadStatus.loaded => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PackagesTable(packages: state.packages),
              const Divider(color: AppColors.cardBorder),
              AppTableFooter(
                firstIndex: state.firstIndex,
                shownCount: state.packages.length,
                totalCount: state.totalCount,
                currentPage: state.page,
                totalPages: state.totalPages,
                onPageChanged: context.read<PackagesCubit>().goToPage,
              ),
            ],
          ),
        },
      ],
    );
  }
}
