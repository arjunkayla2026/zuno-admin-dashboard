import 'package:zuno_admin_dashboard/features/user_details/data/models/call_record.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/models/recharge_package.dart';

abstract final class UserDetailsMockData {
  static const String lastOnline = '02 Nov 2026, 09:12 AM';

  static final DateTime rangeStart = DateTime(2026, 10, 5);
  static final DateTime rangeEnd = DateTime(2026, 11, 4);

  static const double coinValue = 0.5;
  static const int receivableTopUp = 99;
  static const int deletedAccountAdminProfit = 0;

  static const List<RechargePackage> packages = [
    RechargePackage(price: 49, coins: 100),
    RechargePackage(price: 99, coins: 250),
    RechargePackage(price: 199, coins: 500, bonus: 50),
    RechargePackage(price: 449, coins: 1200, bonus: 200),
    RechargePackage(price: 999, coins: 2500, bonus: 400),
  ];

  static const int defaultPackageIndex = 2;

  static final List<CallRecord> calls = [
    CallRecord(
      date: DateTime(2026, 11, 4),
      hostName: 'Jenniffer',
      type: CallType.audio,
      initiatedTime: '12:14:11 PM',
      endTime: '12:14:41 PM',
      endedBy: 'System – no answer',
      status: CallStatus.notAnswered,
      spendCoins: '0',
      totalSpend: '₹0',
      hostRevenue: '₹12.00',
    ),
    CallRecord(
      date: DateTime(2026, 11, 4),
      hostName: 'Pinkky',
      type: CallType.video,
      initiatedTime: '09:52:41 AM',
      endTime: '09:52:51 AM',
      endedBy: 'Host',
      status: CallStatus.rejected,
      spendCoins: '0',
      totalSpend: '₹0',
      hostRevenue: '₹24.00',
    ),
    CallRecord(
      date: DateTime(2026, 11, 3),
      hostName: 'Divya',
      type: CallType.audio,
      initiatedTime: '05:00:55 PM',
      startTime: '05:01:05 PM',
      endTime: '05:10:35 PM',
      endedBy: 'User',
      status: CallStatus.completed,
      duration: '9m 30s',
      spendCoins: '570',
      totalSpend: '₹285',
      hostRevenue: '₹12.00',
    ),
    CallRecord(
      date: DateTime(2026, 11, 3),
      hostName: 'Nandana',
      type: CallType.video,
      initiatedTime: '03:37:53 PM',
      startTime: '03:38:12 PM',
      endTime: '03:40:27 PM',
      endedBy: 'User',
      status: CallStatus.completed,
      duration: '2m 15s',
      spendCoins: '270',
      totalSpend: '₹135',
      hostRevenue: '₹24.00',
    ),
    CallRecord(
      date: DateTime(2026, 10, 19),
      hostName: 'Jenniffer',
      type: CallType.video,
      initiatedTime: '07:26:27 PM',
      endTime: '07:26:57 PM',
      endedBy: 'System – no answer',
      status: CallStatus.notAnswered,
      spendCoins: '0',
      totalSpend: '₹0',
      hostRevenue: '₹24.00',
    ),
    CallRecord(
      date: DateTime(2026, 10, 9),
      hostName: 'Sana',
      type: CallType.audio,
      initiatedTime: '11:37:03 AM',
      endTime: '11:37:15 AM',
      endedBy: 'Host',
      status: CallStatus.rejected,
      spendCoins: '0',
      totalSpend: '₹0',
      hostRevenue: '₹12.00',
    ),
    CallRecord(
      date: DateTime(2026, 10, 8),
      hostName: 'Nila',
      type: CallType.audio,
      initiatedTime: '10:57:20 AM',
      startTime: '10:57:43 AM',
      endTime: '11:01:59 AM',
      endedBy: 'System – low balance',
      status: CallStatus.lowBalance,
      duration: '4m 16s',
      spendCoins: '256',
      totalSpend: '₹128',
      hostRevenue: '₹12.00',
    ),
  ];
}
