import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_record_count_footer.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_segmented_control.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_state.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_wallet_history_table.dart';

class HostWalletHistoryTab extends StatelessWidget {
  const HostWalletHistoryTab({super.key});

  static const EdgeInsets _toolbarPadding = EdgeInsets.fromLTRB(14, 10, 14, 10);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostDetailsCubit, HostDetailsState>(
      builder: (context, state) {
        final transactions = state.filteredWalletTransactions;

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
                  onChanged: context
                      .read<HostDetailsCubit>()
                      .selectWalletFilter,
                ),
              ),
            ),
            HostWalletHistoryTable(transactions: transactions),
            if (transactions.isEmpty)
              const AppRecordCountFooter(shown: 0, total: 0),
          ],
        );
      },
    );
  }
}
