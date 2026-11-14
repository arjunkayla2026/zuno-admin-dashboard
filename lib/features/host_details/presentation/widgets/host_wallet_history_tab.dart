import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_record_count_footer.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_segmented_control.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_footer.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/wallet_transaction.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_state.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_wallet_history_table.dart';

class HostWalletHistoryTab extends StatelessWidget {
  const HostWalletHistoryTab({super.key});

  static const EdgeInsets _toolbarPadding = EdgeInsets.fromLTRB(14, 10, 14, 10);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostDetailsCubit, HostDetailsState>(
      buildWhen: (previous, current) =>
          previous.wallet != current.wallet ||
          previous.walletFilter != current.walletFilter,
      builder: (context, state) {
        final cubit = context.read<HostDetailsCubit>();
        final view = state.wallet;
        final transactions = view.status == LoadStatus.loaded
            ? view.items
            : const <WalletTransaction>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: _toolbarPadding,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppSegmentedControl<WalletFilter>(
                  options: const {
                    WalletFilter.all: AppStrings.all,
                    WalletFilter.credit: AppStrings.credit,
                    WalletFilter.debit: AppStrings.debit,
                  },
                  value: state.walletFilter,
                  onChanged: cubit.selectWalletFilter,
                ),
              ),
            ),
            HostWalletHistoryTable(transactions: transactions),
            if (view.status == LoadStatus.loading)
              const AppTableLoadingState()
            else if (view.status == LoadStatus.failure)
              AppTableErrorState(
                message: view.error ?? AppStrings.recordsLoadFailed,
                onRetry: cubit.retryWallet,
              )
            else if (transactions.isEmpty)
              const AppRecordCountFooter(shown: 0, total: 0)
            else
              AppTableFooter(
                firstIndex: view.firstIndex,
                shownCount: transactions.length,
                totalCount: null,
                currentPage: view.page,
                totalPages: view.totalPages,
                onPageChanged: cubit.goToWalletPage,
              ),
          ],
        );
      },
    );
  }
}
