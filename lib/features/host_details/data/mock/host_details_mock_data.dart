import 'package:zuno_admin_dashboard/core/enums/wallet_adjustment_type.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
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

  static const int totalRevenue = 32949;
  static const int totalSuccessfulWithdrawals = 23723;
  static const int totalPendingWithdrawals = 2818;
  static const int totalCreditFromAdmin = 100;
  static const int totalDebitFromAdmin = 0;
  static const int deletedAccountAdminProfit = 0;
}
