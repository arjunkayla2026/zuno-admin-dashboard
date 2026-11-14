import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_record_count_footer.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_footer.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_state.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_withdrawal_history_table.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class HostWithdrawalHistoryTab extends StatelessWidget {
  const HostWithdrawalHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostDetailsCubit, HostDetailsState>(
      buildWhen: (previous, current) =>
          previous.withdrawals != current.withdrawals ||
          previous.withdrawalCount != current.withdrawalCount,
      builder: (context, state) {
        final cubit = context.read<HostDetailsCubit>();
        final view = state.withdrawals;
        final rows = view.status == LoadStatus.loaded
            ? view.items
            : const <Withdrawal>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HostWithdrawalHistoryTable(withdrawals: rows),
            if (view.status == LoadStatus.loading)
              const AppTableLoadingState()
            else if (view.status == LoadStatus.failure)
              AppTableErrorState(
                message: view.error ?? AppStrings.recordsLoadFailed,
                onRetry: cubit.retryWithdrawals,
              )
            else if (rows.isEmpty)
              const AppRecordCountFooter(shown: 0, total: 0)
            else
              AppTableFooter(
                firstIndex: view.firstIndex,
                shownCount: rows.length,
                totalCount: state.withdrawalCount,
                currentPage: view.page,
                totalPages: view.totalPages,
                onPageChanged: cubit.goToWithdrawalPage,
              ),
          ],
        );
      },
    );
  }
}
