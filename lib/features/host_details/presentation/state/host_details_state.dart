import 'package:zuno_admin_dashboard/core/enums/wallet_adjustment_type.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_stat_cards.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/mock/host_details_mock_data.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/host_withdrawal.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/wallet_transaction.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';

enum HostDetailsTab { calls, withdrawals, wallet }

enum WalletFilter { all, credit, debit }

class HostDetailsState {
  const HostDetailsState({
    required this.host,
    required this.withdrawals,
    required this.walletTransactions,
    required this.totalCredit,
    required this.totalDebit,
    this.tab = HostDetailsTab.calls,
    this.walletFilter = WalletFilter.all,
  });

  final AdminHost host;
  final List<HostWithdrawal> withdrawals;
  final List<WalletTransaction> walletTransactions;
  final WalletFilter walletFilter;
  final int totalCredit;
  final int totalDebit;
  final HostDetailsTab tab;

  List<AppStat> get stats => [
    AppStat(
      label: AppStrings.totalRevenue,
      value: NumberFormatter.rupees(HostDetailsMockData.totalRevenue),
    ),
    AppStat(
      label: AppStrings.totalSuccessfulWithdrawals,
      value: NumberFormatter.rupees(
        HostDetailsMockData.totalSuccessfulWithdrawals,
      ),
    ),
    AppStat(
      label: AppStrings.totalPendingWithdrawals,
      value: NumberFormatter.rupees(
        HostDetailsMockData.totalPendingWithdrawals,
      ),
    ),
    AppStat(
      label: AppStrings.availableWalletAmount,
      value: NumberFormatter.rupees(host.walletBalance),
    ),
    AppStat(
      label: AppStrings.totalCreditFromAdmin,
      value: NumberFormatter.rupees(totalCredit),
    ),
    AppStat(
      label: AppStrings.totalDebitFromAdmin,
      value: NumberFormatter.rupees(totalDebit),
    ),
    AppStat(
      label: AppStrings.deletedAccountAdminProfit,
      value: NumberFormatter.rupees(
        HostDetailsMockData.deletedAccountAdminProfit,
      ),
    ),
  ];

  List<WalletTransaction> get filteredWalletTransactions =>
      walletTransactions.where((transaction) {
        return switch (walletFilter) {
          WalletFilter.all => true,
          WalletFilter.credit =>
            transaction.type == WalletAdjustmentType.credit,
          WalletFilter.debit => transaction.type == WalletAdjustmentType.debit,
        };
      }).toList();

  HostDetailsState copyWith({
    AdminHost? host,
    List<WalletTransaction>? walletTransactions,
    WalletFilter? walletFilter,
    int? totalCredit,
    int? totalDebit,
    HostDetailsTab? tab,
  }) {
    return HostDetailsState(
      host: host ?? this.host,
      withdrawals: withdrawals,
      walletTransactions: walletTransactions ?? this.walletTransactions,
      walletFilter: walletFilter ?? this.walletFilter,
      totalCredit: totalCredit ?? this.totalCredit,
      totalDebit: totalDebit ?? this.totalDebit,
      tab: tab ?? this.tab,
    );
  }
}
