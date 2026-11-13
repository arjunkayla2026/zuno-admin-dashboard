import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_stat_cards.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/mock/user_details_mock_data.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

enum UserDetailsTab { calls, recharges }

class UserDetailsState {
  const UserDetailsState({
    required this.user,
    this.totalRecharge = 0,
    this.availableCoins = 0,
    this.summaryStatus = LoadStatus.loading,
    this.tab = UserDetailsTab.calls,
  });

  final AdminUser user;
  final double totalRecharge;
  final int availableCoins;
  final LoadStatus summaryStatus;
  final UserDetailsTab tab;

  int get walletBalance => NumberFormatter.parse(user.walletBalance);

  String _summaryValue(String Function() value) =>
      summaryStatus == LoadStatus.loaded ? value() : AppStrings.emptyValue;

  List<AppStat> get stats => [
    AppStat(
      label: AppStrings.totalRecharge,
      value: _summaryValue(() => NumberFormatter.rupeesAmount(totalRecharge)),
    ),
    AppStat(
      label: AppStrings.availableCoins,
      value: _summaryValue(() => NumberFormatter.grouped(availableCoins)),
    ),
    AppStat(
      label: AppStrings.availableCoinsAmount,
      value: _summaryValue(
        () => NumberFormatter.rupees(
          (availableCoins * UserDetailsMockData.coinValue).floor(),
        ),
      ),
    ),
    AppStat(
      label: AppStrings.receivableTopUp,
      value: NumberFormatter.rupees(UserDetailsMockData.receivableTopUp),
    ),
    AppStat(
      label: AppStrings.totalCreditFromAdmin,
      value: NumberFormatter.rupees(user.adminCredit),
    ),
    AppStat(
      label: AppStrings.totalDebitFromAdmin,
      value: NumberFormatter.rupees(user.adminDebit),
    ),
    AppStat(
      label: AppStrings.deletedAccountAdminProfit,
      value: NumberFormatter.rupees(
        UserDetailsMockData.deletedAccountAdminProfit,
      ),
    ),
  ];

  UserDetailsState copyWith({
    AdminUser? user,
    double? totalRecharge,
    int? availableCoins,
    LoadStatus? summaryStatus,
    UserDetailsTab? tab,
  }) {
    return UserDetailsState(
      user: user ?? this.user,
      totalRecharge: totalRecharge ?? this.totalRecharge,
      availableCoins: availableCoins ?? this.availableCoins,
      summaryStatus: summaryStatus ?? this.summaryStatus,
      tab: tab ?? this.tab,
    );
  }
}
