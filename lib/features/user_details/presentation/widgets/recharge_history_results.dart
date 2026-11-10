import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_footer.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_recharge_history_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_recharge_history_state.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/recharge_history_table.dart';

class RechargeHistoryResults extends StatelessWidget {
  const RechargeHistoryResults({super.key});

  static const double _emptyHeight = 160;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRechargeHistoryCubit, UserRechargeHistoryState>(
      builder: (context, state) {
        final transactions = state.transactions;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RechargeHistoryTable(transactions: transactions),
            if (state.status == LoadStatus.loading)
              const AppTableLoadingState()
            else if (state.status == LoadStatus.failure)
              AppTableErrorState(
                message: state.errorMessage ?? AppStrings.recordsLoadFailed,
                onRetry: context.read<UserRechargeHistoryCubit>().load,
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
                onPageChanged: context
                    .read<UserRechargeHistoryCubit>()
                    .goToPage,
              ),
          ],
        );
      },
    );
  }
}
