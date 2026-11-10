import 'package:zuno_admin_dashboard/core/enums/call_filter.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_stat_cards.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/mock/user_details_mock_data.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/models/call_record.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

enum UserDetailsTab { calls, recharges }

class UserDetailsState {
  const UserDetailsState({
    required this.user,
    required this.calls,
    required this.rangeStart,
    required this.rangeEnd,
    required this.singleDate,
    this.totalRecharge = 0,
    this.availableCoins = 0,
    this.summaryStatus = LoadStatus.loading,
    this.tab = UserDetailsTab.calls,
    this.typeFilter = CallTypeFilter.all,
    this.dateMode = CallDateMode.range,
  });

  final AdminUser user;
  final List<CallRecord> calls;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final DateTime singleDate;
  final double totalRecharge;
  final int availableCoins;
  final LoadStatus summaryStatus;
  final UserDetailsTab tab;
  final CallTypeFilter typeFilter;
  final CallDateMode dateMode;

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

  bool _matchesDate(DateTime date) => switch (dateMode) {
    CallDateMode.single => date == singleDate,
    CallDateMode.range => !date.isBefore(rangeStart) && !date.isAfter(rangeEnd),
  };

  bool _matchesType(CallType type) => switch (typeFilter) {
    CallTypeFilter.all => true,
    CallTypeFilter.audio => type == CallType.audio,
    CallTypeFilter.video => type == CallType.video,
  };

  List<CallRecord> get filteredCalls => calls
      .where((call) => _matchesType(call.type) && _matchesDate(call.date))
      .toList();

  UserDetailsState copyWith({
    AdminUser? user,
    double? totalRecharge,
    int? availableCoins,
    LoadStatus? summaryStatus,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    DateTime? singleDate,
    UserDetailsTab? tab,
    CallTypeFilter? typeFilter,
    CallDateMode? dateMode,
  }) {
    return UserDetailsState(
      user: user ?? this.user,
      calls: calls,
      totalRecharge: totalRecharge ?? this.totalRecharge,
      availableCoins: availableCoins ?? this.availableCoins,
      summaryStatus: summaryStatus ?? this.summaryStatus,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      singleDate: singleDate ?? this.singleDate,
      tab: tab ?? this.tab,
      typeFilter: typeFilter ?? this.typeFilter,
      dateMode: dateMode ?? this.dateMode,
    );
  }
}
