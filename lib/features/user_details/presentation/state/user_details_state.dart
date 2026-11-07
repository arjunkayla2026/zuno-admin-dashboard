import 'package:zuno_admin_dashboard/core/enums/call_filter.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_stat_cards.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/mock/user_details_mock_data.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/models/call_record.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/models/recharge_record.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

enum UserDetailsTab { calls, recharges }

class UserDetailsState {
  const UserDetailsState({
    required this.user,
    required this.calls,
    required this.recharges,
    required this.rangeStart,
    required this.rangeEnd,
    required this.singleDate,
    required this.totalRecharge,
    required this.availableCoins,
    this.tab = UserDetailsTab.calls,
    this.typeFilter = CallTypeFilter.all,
    this.dateMode = CallDateMode.range,
    this.rechargeQuery = '',
  });

  final AdminUser user;
  final List<CallRecord> calls;
  final List<RechargeRecord> recharges;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final DateTime singleDate;
  final int totalRecharge;
  final int availableCoins;
  final UserDetailsTab tab;
  final CallTypeFilter typeFilter;
  final CallDateMode dateMode;
  final String rechargeQuery;

  List<AppStat> get stats => [
    AppStat(
      label: AppStrings.totalRecharge,
      value: NumberFormatter.rupees(totalRecharge),
    ),
    AppStat(
      label: AppStrings.availableCoins,
      value: NumberFormatter.grouped(availableCoins),
    ),
    AppStat(
      label: AppStrings.availableCoinsAmount,
      value: NumberFormatter.rupees(
        (availableCoins * UserDetailsMockData.coinValue).floor(),
      ),
    ),
    AppStat(
      label: AppStrings.receivableTopUp,
      value: NumberFormatter.rupees(UserDetailsMockData.receivableTopUp),
    ),
    AppStat(
      label: AppStrings.totalCreditFromAdmin,
      value: NumberFormatter.rupees(UserDetailsMockData.totalCreditFromAdmin),
    ),
    AppStat(
      label: AppStrings.totalDebitFromAdmin,
      value: NumberFormatter.rupees(UserDetailsMockData.totalDebitFromAdmin),
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

  List<RechargeRecord> get filteredRecharges {
    final term = rechargeQuery.trim().toLowerCase();
    if (term.isEmpty) return recharges;
    final amountTerm = term.replaceAll(RegExp(r'[₹,]'), '');
    return recharges.where((recharge) {
      final paymentId = recharge.paymentId?.toLowerCase() ?? '';
      final amount = recharge.amount.replaceAll(RegExp(r'[₹,]'), '');
      return paymentId.contains(term) ||
          (amountTerm.isNotEmpty && amount.contains(amountTerm));
    }).toList();
  }

  UserDetailsState copyWith({
    AdminUser? user,
    List<RechargeRecord>? recharges,
    int? totalRecharge,
    int? availableCoins,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    DateTime? singleDate,
    UserDetailsTab? tab,
    CallTypeFilter? typeFilter,
    CallDateMode? dateMode,
    String? rechargeQuery,
  }) {
    return UserDetailsState(
      user: user ?? this.user,
      calls: calls,
      recharges: recharges ?? this.recharges,
      totalRecharge: totalRecharge ?? this.totalRecharge,
      availableCoins: availableCoins ?? this.availableCoins,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      singleDate: singleDate ?? this.singleDate,
      tab: tab ?? this.tab,
      typeFilter: typeFilter ?? this.typeFilter,
      dateMode: dateMode ?? this.dateMode,
      rechargeQuery: rechargeQuery ?? this.rechargeQuery,
    );
  }
}
