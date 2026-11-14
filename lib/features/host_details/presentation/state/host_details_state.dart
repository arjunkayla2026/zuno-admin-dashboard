import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/enums/wallet_adjustment_type.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_stat_cards.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/host_earnings_totals.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/wallet_transaction.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

enum HostDetailsTab { calls, withdrawals, wallet }

enum WalletFilter { all, credit, debit }

class HostDetailsState {
  const HostDetailsState({
    required this.host,
    this.tab = HostDetailsTab.calls,
    this.walletFilter = WalletFilter.all,
    this.totals,
    this.withdrawalCount,
    this.withdrawals = const CursorPageView(
      items: <Withdrawal>[],
      status: LoadStatus.loading,
      page: 1,
    ),
    this.wallet = const CursorPageView(
      items: <WalletTransaction>[],
      status: LoadStatus.loading,
      page: 1,
    ),
    this.adjusting = false,
  });

  final AdminHost host;
  final HostDetailsTab tab;
  final WalletFilter walletFilter;
  final HostEarningsTotals? totals;
  final int? withdrawalCount;
  final CursorPageView<Withdrawal> withdrawals;
  final CursorPageView<WalletTransaction> wallet;
  final bool adjusting;

  double get pendingTotal => totals?.pendingTotal ?? 0;

  WalletAdjustmentType? get walletType => switch (walletFilter) {
    WalletFilter.all => null,
    WalletFilter.credit => WalletAdjustmentType.credit,
    WalletFilter.debit => WalletAdjustmentType.debit,
  };

  List<AppStat> get stats {
    final totals = this.totals;
    String amount(double? value) => value == null
        ? AppStrings.emptyValue
        : NumberFormatter.rupeesAmount(value);

    return [
      AppStat(
        label: AppStrings.totalRevenue,
        value: NumberFormatter.rupeesAmount(host.totalRevenue),
      ),
      AppStat(
        label: AppStrings.totalSuccessfulWithdrawals,
        value: amount(totals?.paidTotal),
      ),
      AppStat(
        label: AppStrings.totalPendingWithdrawals,
        value: amount(totals?.pendingTotal),
      ),
      AppStat(
        label: AppStrings.availableWalletAmount,
        value: NumberFormatter.rupees(host.walletBalance),
      ),
      AppStat(
        label: AppStrings.totalCreditFromAdmin,
        value: amount(totals?.adminCredit),
      ),
      AppStat(
        label: AppStrings.totalDebitFromAdmin,
        value: amount(totals?.adminDebit),
      ),
      AppStat(
        label: AppStrings.deletedAccountAdminProfit,
        value: host.isDeleted
            ? amount(totals?.pendingTotal)
            : NumberFormatter.rupeesAmount(0),
      ),
    ];
  }

  HostDetailsState copyWith({
    AdminHost? host,
    HostDetailsTab? tab,
    WalletFilter? walletFilter,
    HostEarningsTotals? totals,
    int? withdrawalCount,
    CursorPageView<Withdrawal>? withdrawals,
    CursorPageView<WalletTransaction>? wallet,
    bool? adjusting,
  }) {
    return HostDetailsState(
      host: host ?? this.host,
      tab: tab ?? this.tab,
      walletFilter: walletFilter ?? this.walletFilter,
      totals: totals ?? this.totals,
      withdrawalCount: withdrawalCount ?? this.withdrawalCount,
      withdrawals: withdrawals ?? this.withdrawals,
      wallet: wallet ?? this.wallet,
      adjusting: adjusting ?? this.adjusting,
    );
  }
}
