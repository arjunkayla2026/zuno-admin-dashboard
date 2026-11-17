import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/coin_converter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_stat_cards.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

enum UserDetailsTab { calls, recharges }

class UserDetailsState {
  const UserDetailsState({
    required this.user,
    this.totalRecharge = 0,
    this.receivableTopUp = 0,
    this.adminCreditTotal = 0,
    this.adminDebitTotal = 0,
    this.summaryStatus = LoadStatus.loading,
    this.deletedAccountProfit = 0,
    this.profitStatus = LoadStatus.loading,
    this.tab = UserDetailsTab.calls,
  });

  final AdminUser user;
  final double totalRecharge;
  final double receivableTopUp;
  final double adminCreditTotal;
  final double adminDebitTotal;
  final LoadStatus summaryStatus;
  final double deletedAccountProfit;
  final LoadStatus profitStatus;
  final UserDetailsTab tab;

  /// The exact `walletBalance` in rupees.
  double get walletBalance => user.walletRupees;

  /// Coins the user sees in the app: `walletBalance × 15`, rounded down
  /// exactly like the calling app's `CoinConverter.rupeesToCoins`.
  int get availableCoins => CoinConverter.rupeesToCoins(walletBalance);

  String _summaryValue(String Function() value) =>
      summaryStatus == LoadStatus.loaded ? value() : AppStrings.emptyValue;

  List<AppStat> get stats => [
    AppStat(
      label: AppStrings.totalRecharge,
      value: _summaryValue(() => NumberFormatter.rupeesAmount(totalRecharge)),
    ),
    AppStat(
      label: AppStrings.availableCoins,
      value: NumberFormatter.grouped(availableCoins),
    ),
    AppStat(
      label: AppStrings.availableCoinsAmount,
      value: NumberFormatter.rupeesAmount(walletBalance),
    ),
    AppStat(
      label: AppStrings.receivableTopUp,
      value: _summaryValue(
        () => NumberFormatter.rupeesAmount(receivableTopUp),
      ),
    ),
    AppStat(
      label: AppStrings.totalCreditFromAdmin,
      value: _summaryValue(
        () => NumberFormatter.rupeesAmount(adminCreditTotal),
      ),
    ),
    AppStat(
      label: AppStrings.totalDebitFromAdmin,
      value: _summaryValue(() => NumberFormatter.rupeesAmount(adminDebitTotal)),
    ),
    AppStat(
      label: AppStrings.deletedAccountAdminProfit,
      value: user.hasActions
          ? NumberFormatter.rupees(0)
          : profitStatus == LoadStatus.loaded
          ? NumberFormatter.rupeesAmount(deletedAccountProfit)
          : AppStrings.emptyValue,
    ),
  ];

  UserDetailsState copyWith({
    AdminUser? user,
    double? totalRecharge,
    double? receivableTopUp,
    double? adminCreditTotal,
    double? adminDebitTotal,
    LoadStatus? summaryStatus,
    double? deletedAccountProfit,
    LoadStatus? profitStatus,
    UserDetailsTab? tab,
  }) {
    return UserDetailsState(
      user: user ?? this.user,
      totalRecharge: totalRecharge ?? this.totalRecharge,
      receivableTopUp: receivableTopUp ?? this.receivableTopUp,
      adminCreditTotal: adminCreditTotal ?? this.adminCreditTotal,
      adminDebitTotal: adminDebitTotal ?? this.adminDebitTotal,
      summaryStatus: summaryStatus ?? this.summaryStatus,
      deletedAccountProfit: deletedAccountProfit ?? this.deletedAccountProfit,
      profitStatus: profitStatus ?? this.profitStatus,
      tab: tab ?? this.tab,
    );
  }
}
