import 'package:zuno_admin_dashboard/core/data/cursor_pager.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/enums/wallet_adjustment_type.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_stat_cards.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/bank_account_record.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/admin_adjustment_totals.dart';
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
    this.ledgerAdjustments,
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
    this.bankAccount,
    this.bankAccountStatus = LoadStatus.loading,
    this.bankAccountError,
    this.savingBankAccount = false,
  });

  final AdminHost host;
  final HostDetailsTab tab;
  final WalletFilter walletFilter;
  final HostEarningsTotals? totals;

  /// Admin credit / debit added up from the host's ledger entries.
  final AdminAdjustmentTotals? ledgerAdjustments;
  final int? withdrawalCount;
  final CursorPageView<Withdrawal> withdrawals;
  final CursorPageView<WalletTransaction> wallet;
  final bool adjusting;
  final BankAccountRecord? bankAccount;
  final LoadStatus bankAccountStatus;
  final String? bankAccountError;
  final bool savingBankAccount;

  /// Total of the host's admin credits from the ledger; until that loads
  /// (or if it fails) the stored `hostEarnings.totalAdminCredit`, if any.
  double? get adminCreditTotal =>
      ledgerAdjustments?.credit ?? host.totalAdminCredit;

  /// Total of the host's admin debits from the ledger; until that loads
  /// (or if it fails) the stored `hostEarnings.totalAdminDebit`, if any.
  double? get adminDebitTotal =>
      ledgerAdjustments?.debit ?? host.totalAdminDebit;

  /// The host's stored withdrawn total (`hostEarnings.totalWithdrawel`);
  /// for a host without it, the `totalAmount` of its `success` payouts once
  /// the payout totals load.
  double? get successfulWithdrawals => host.totalWithdrawn ?? totals?.paidTotal;

  /// `totalAmount` of the host's `pending` and `failed` payouts (moved to
  /// payment, not paid yet); null until the payout totals load.
  double? get pendingWithdrawals => totals?.awaitingPaymentTotal;

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
      // Total Revenue: `hostDetails.hostEarnings.totalEarnings`.
      // Successful: `hostDetails.hostEarnings.totalWithdrawel`. Pending:
      // `totalAmount` of `pending` + `failed` payouts.
      AppStat(
        label: AppStrings.totalRevenue,
        value: NumberFormatter.rupeesAmount(host.totalRevenue),
      ),
      AppStat(
        label: AppStrings.totalSuccessfulWithdrawals,
        value: amount(successfulWithdrawals),
      ),
      AppStat(
        label: AppStrings.totalPendingWithdrawals,
        value: amount(pendingWithdrawals),
      ),
      // `hostDetails.hostEarnings.availableBalance`.
      AppStat(
        label: AppStrings.availableWalletAmount,
        value: NumberFormatter.rupeesAmount(host.availableBalance),
      ),
      AppStat(
        label: AppStrings.totalCreditFromAdmin,
        value: amount(adminCreditTotal),
      ),
      AppStat(
        label: AppStrings.totalDebitFromAdmin,
        value: amount(adminDebitTotal),
      ),
      AppStat(
        label: AppStrings.deletedAccountAdminProfit,
        value: host.isDeleted
            ? amount(totals?.deletedAccountProfit)
            : NumberFormatter.rupeesAmount(0),
      ),
    ];
  }

  HostDetailsState copyWith({
    AdminHost? host,
    HostDetailsTab? tab,
    WalletFilter? walletFilter,
    HostEarningsTotals? totals,
    bool clearTotals = false,
    AdminAdjustmentTotals? ledgerAdjustments,
    bool clearLedgerAdjustments = false,
    int? withdrawalCount,
    CursorPageView<Withdrawal>? withdrawals,
    CursorPageView<WalletTransaction>? wallet,
    bool? adjusting,
    BankAccountRecord? bankAccount,
    bool clearBankAccount = false,
    LoadStatus? bankAccountStatus,
    String? bankAccountError,
    bool? savingBankAccount,
  }) {
    return HostDetailsState(
      host: host ?? this.host,
      tab: tab ?? this.tab,
      walletFilter: walletFilter ?? this.walletFilter,
      totals: clearTotals ? null : totals ?? this.totals,
      ledgerAdjustments: clearLedgerAdjustments
          ? null
          : ledgerAdjustments ?? this.ledgerAdjustments,
      withdrawalCount: withdrawalCount ?? this.withdrawalCount,
      withdrawals: withdrawals ?? this.withdrawals,
      wallet: wallet ?? this.wallet,
      adjusting: adjusting ?? this.adjusting,
      bankAccount: clearBankAccount ? null : bankAccount ?? this.bankAccount,
      bankAccountStatus: bankAccountStatus ?? this.bankAccountStatus,
      bankAccountError: bankAccountStatus == null
          ? this.bankAccountError
          : bankAccountError,
      savingBankAccount: savingBankAccount ?? this.savingBankAccount,
    );
  }
}
