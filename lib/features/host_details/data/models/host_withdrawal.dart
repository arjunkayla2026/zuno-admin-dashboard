enum HostWithdrawalStatus { pending, success }

class HostWithdrawal {
  const HostWithdrawal({
    required this.date,
    required this.callCount,
    required this.callMinutes,
    required this.amountEarned,
    required this.withdrawAmount,
    required this.branchName,
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.withdrawId,
    required this.status,
    this.surgeCharge,
  });

  final DateTime date;
  final int callCount;
  final int callMinutes;
  final int amountEarned;
  final int? surgeCharge;
  final int withdrawAmount;
  final String branchName;
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String withdrawId;
  final HostWithdrawalStatus status;
}
