import 'package:zuno_admin_dashboard/core/enums/wallet_adjustment_type.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/host_call_record.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/host_withdrawal.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/wallet_transaction.dart';

abstract final class HostDetailsMockData {
  static const String _callEarnings = 'Call earnings';
  static const String _branchName = 'Bengaluru Indiranagar';
  static const String _accountHolder = 'Nandana Suresh';
  static const String _accountNumber = '145439964558';
  static const String _ifscCode = 'UTIB0003759';

  static final List<HostWithdrawal> withdrawals = [
    HostWithdrawal(
      date: DateTime(2026, 11, 3),
      callCount: 101,
      callMinutes: 453,
      amountEarned: 5436,
      surgeCharge: 120,
      withdrawAmount: 5556,
      branchName: _branchName,
      accountHolderName: _accountHolder,
      accountNumber: _accountNumber,
      ifscCode: _ifscCode,
      withdrawId: 'WD55100',
      status: HostWithdrawalStatus.pending,
    ),
    HostWithdrawal(
      date: DateTime(2026, 10, 19),
      callCount: 127,
      callMinutes: 266,
      amountEarned: 3192,
      withdrawAmount: 3192,
      branchName: _branchName,
      accountHolderName: _accountHolder,
      accountNumber: _accountNumber,
      ifscCode: _ifscCode,
      withdrawId: 'WD54829',
      status: HostWithdrawalStatus.success,
    ),
  ];

  static WalletTransaction _credit(DateTime date, int amount, String note) =>
      WalletTransaction(
        date: date,
        type: WalletAdjustmentType.credit,
        amount: amount,
        description: note,
      );

  static final List<WalletTransaction> walletTransactions = [
    _credit(DateTime(2026, 11, 3), 215, _callEarnings),
    _credit(DateTime(2026, 10, 30), 284, _callEarnings),
    WalletTransaction(
      date: DateTime(2026, 10, 27),
      type: WalletAdjustmentType.debit,
      amount: 50,
      description: AppStrings.adminDebit,
    ),
    _credit(DateTime(2026, 10, 21), 86, _callEarnings),
    _credit(DateTime(2026, 10, 17), 728, _callEarnings),
    _credit(DateTime(2026, 10, 14), 548, _callEarnings),
    _credit(DateTime(2026, 10, 9), 250, AppStrings.adminCredit),
    _credit(DateTime(2026, 10, 5), 250, AppStrings.adminCredit),
    _credit(DateTime(2026, 10, 1), 646, _callEarnings),
    _credit(DateTime(2026, 9, 27), 101, _callEarnings),
  ];

  static const String lastOnline = '04 Nov 2026, 04:23 PM';
  static const bool isOnline = false;
  static const String maskedAadhaar = 'XXXX XXXX 7749';

  static final DateTime rangeStart = DateTime(2026, 10, 5);
  static final DateTime rangeEnd = DateTime(2026, 11, 4);

  static const int totalRevenue = 32949;
  static const int totalSuccessfulWithdrawals = 23723;
  static const int totalPendingWithdrawals = 2818;
  static const int totalCreditFromAdmin = 100;
  static const int totalDebitFromAdmin = 0;
  static const int deletedAccountAdminProfit = 0;

  static final List<HostCallRecord> calls = [
    HostCallRecord(
      date: DateTime(2026, 11, 4),
      userName: 'Sanjay Rao',
      userId: 'ZH10290',
      type: HostCallType.audio,
      initiatedTime: '09:39:09 PM',
      startTime: '09:39:18 PM',
      endTime: '09:49:06 PM',
      endedBy: 'User',
      duration: '9m 50s',
      status: HostCallStatus.completed,
      spendCoins: '590',
      totalSpend: '₹295',
      hostRevenue: '₹147.50',
    ),
    HostCallRecord(
      date: DateTime(2026, 11, 3),
      userName: 'Rahul Menon',
      userId: 'ZH10291',
      type: HostCallType.video,
      initiatedTime: '07:39:59 PM',
      startTime: '07:40:15 PM',
      endTime: '07:42:09 PM',
      endedBy: 'System – low balance',
      duration: '1m 54s',
      status: HostCallStatus.lowBalance,
      spendCoins: '228',
      totalSpend: '₹114',
      hostRevenue: '₹57.00',
    ),
    HostCallRecord(
      date: DateTime(2026, 11, 3),
      userName: 'Arjun Nair',
      userId: 'ZH10292',
      type: HostCallType.video,
      initiatedTime: '03:37:53 PM',
      startTime: '03:38:12 PM',
      endTime: '03:40:27 PM',
      endedBy: 'User',
      duration: '2m 15s',
      status: HostCallStatus.completed,
      spendCoins: '270',
      totalSpend: '₹135',
      hostRevenue: '₹67.50',
    ),
    HostCallRecord(
      date: DateTime(2026, 11, 3),
      userName: 'Vishnu Das',
      userId: 'ZH10293',
      type: HostCallType.video,
      initiatedTime: '08:28:28 AM',
      endTime: '08:28:10 AM',
      endedBy: 'System – host busy',
      status: HostCallStatus.busy,
      spendCoins: '0',
      totalSpend: '₹0',
      hostRevenue: '₹0',
    ),
    HostCallRecord(
      date: DateTime(2026, 10, 11),
      userName: 'Suhail Ahmed',
      userId: 'ZH10294',
      type: HostCallType.audio,
      initiatedTime: '09:36:16 AM',
      endTime: '09:36:40 AM',
      endedBy: 'Host',
      status: HostCallStatus.rejected,
      spendCoins: '0',
      totalSpend: '₹0',
      hostRevenue: '₹0',
    ),
  ];
}
