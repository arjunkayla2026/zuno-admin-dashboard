import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';

enum WithdrawalStatus { pending, success }

class Withdrawal {
  const Withdrawal({
    required this.withdrawId,
    required this.date,
    required this.hostName,
    required this.hostId,
    required this.phone,
    required this.avatarIndex,
    required this.callCount,
    required this.callMinutes,
    required this.amountEarned,
    required this.totalAmount,
    required this.branchName,
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    this.status = WithdrawalStatus.pending,
    this.paidOn,
    this.appliedTdsPercent,
  });

  static const int _visibleDigits = 4;
  static const int _paisePerRupee = 100;

  final String withdrawId;
  final DateTime date;
  final String hostName;
  final String hostId;
  final String phone;
  final int avatarIndex;
  final int callCount;
  final int callMinutes;
  final int amountEarned;
  final int totalAmount;
  final String branchName;
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final WithdrawalStatus status;
  final DateTime? paidOn;
  final int? appliedTdsPercent;

  String get initials => NameFormatter.initials(hostName);

  bool get isPending => status == WithdrawalStatus.pending;

  DateTime get settledDate => paidOn ?? date;

  int get hostCredit => totalAmount - amountEarned;

  int tdsPaise(int percent) => totalAmount * percent;

  int receivablePaise(int percent) =>
      totalAmount * _paisePerRupee - tdsPaise(percent);

  String get accountLastDigits => accountNumber.length <= _visibleDigits
      ? accountNumber
      : accountNumber.substring(accountNumber.length - _visibleDigits);

  Withdrawal copyWith({
    WithdrawalStatus? status,
    DateTime? paidOn,
    int? appliedTdsPercent,
  }) {
    return Withdrawal(
      withdrawId: withdrawId,
      date: date,
      hostName: hostName,
      hostId: hostId,
      phone: phone,
      avatarIndex: avatarIndex,
      callCount: callCount,
      callMinutes: callMinutes,
      amountEarned: amountEarned,
      totalAmount: totalAmount,
      branchName: branchName,
      accountHolderName: accountHolderName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      status: status ?? this.status,
      paidOn: paidOn ?? this.paidOn,
      appliedTdsPercent: appliedTdsPercent ?? this.appliedTdsPercent,
    );
  }
}
