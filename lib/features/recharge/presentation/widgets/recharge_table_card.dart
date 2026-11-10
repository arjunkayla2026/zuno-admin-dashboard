import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_footer.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/state/recharge_cubit.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/state/recharge_state.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/widgets/recharge_table.dart';

class RechargeTableCard extends StatelessWidget {
  const RechargeTableCard({super.key});

  static const double _emptyHeight = 160;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RechargeCubit, RechargeState>(
      builder: (context, state) {
        final isLoaded = state.status == LoadStatus.loaded;
        final transactions = isLoaded
            ? state.transactions
            : const <RechargeTransaction>[];

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
              RechargeTable(transactions: transactions),
              if (state.status == LoadStatus.loading)
                const AppTableLoadingState()
              else if (state.status == LoadStatus.failure)
                AppTableErrorState(
                  message: state.errorMessage ?? AppStrings.recordsLoadFailed,
                  onRetry: context.read<RechargeCubit>().loadRecharges,
                )
              else if (transactions.isEmpty)
                SizedBox(
                  height: _emptyHeight,
                  child: Center(
                    child: Text(
                      AppStrings.noRechargesFound,
                      style: AppTextStyles.tableCell.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                AppTableFooter(
                  firstIndex: state.firstIndex,
                  shownCount: transactions.length,
                  totalCount: null,
                  currentPage: state.page,
                  totalPages: state.totalPages,
                  onPageChanged: context.read<RechargeCubit>().goToPage,
                ),
            ],
          ),
        );
      },
    );
  }
}
