import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';

enum WithdrawalStatus { pending, success }

class PayoutBankAccount {
  const PayoutBankAccount({
    this.accountHolderName,
    this.branchName,
    this.accountNumber,
    this.ifscCode,
  });

  static PayoutBankAccount? fromMap(Object? value) {
    if (value is! Map) return null;
    return PayoutBankAccount(
      accountHolderName: UserRecord.readText(value['accountHolderName']),
      branchName: UserRecord.readText(value['branchName']),
      accountNumber: UserRecord.readText(value['accountNo']),
      ifscCode: UserRecord.readText(value['ifscCode']),
    );
  }

  final String? accountHolderName;
  final String? branchName;
  final String? accountNumber;
  final String? ifscCode;
}

class PayoutReceipt {
  const PayoutReceipt({
    required this.totalAmount,
    required this.tdsPercent,
    required this.tdsAmount,
    required this.receivableAmount,
  });

  factory PayoutReceipt.fromMap(Map<Object?, Object?>? data) {
    double amount(String key) {
      final value = data?[key];
      return value is num ? value.toDouble() : 0;
    }

    final percent = data?['tdsPercent'];
    return PayoutReceipt(
      totalAmount: amount('totalAmount'),
      tdsPercent: percent is num ? percent.round() : 0,
      tdsAmount: amount('tdsAmount'),
      receivableAmount: amount('receivableAmount'),
    );
  }

  final double totalAmount;
  final int tdsPercent;
  final double tdsAmount;
  final double receivableAmount;
}

class Withdrawal {
  const Withdrawal({
    required this.id,
    required this.withdrawId,
    required this.hostId,
    required this.hostUserId,
    required this.hostName,
    required this.phone,
    required this.date,
    this.callCount = 0,
    this.callSeconds = 0,
    this.amountEarned = 0,
    this.surgeEarnings = 0,
    this.adminCreditAmount = 0,
    this.adminDebitAmount = 0,
    this.bonusAmount = 0,
    this.totalAmount = 0,
    this.status = WithdrawalStatus.pending,
    this.paidOn,
    this.appliedTdsPercent,
    this.paidTdsAmount,
    this.paidReceivableAmount,
    this.bankAccount,
  });

  factory Withdrawal.fromDocument(String id, Map<String, dynamic> data) {
    int count(String field) {
      final value = data[field];
      return value is num ? value.round() : 0;
    }

    double amount(String field) {
      final value = data[field];
      return value is num ? NumberFormatter.roundAmount(value.toDouble()) : 0;
    }

    double? paidAmount(String field) =>
        data[field] is num ? amount(field) : null;

    final isPaid = data[statusField] == successStatus;
    final tdsPercent = data[tdsPercentField];
    return Withdrawal(
      id: id,
      withdrawId: UserRecord.readText(data[withdrawIdField]) ?? id,
      hostId: UserRecord.readText(data[hostIdField]) ?? '',
      hostUserId:
          UserRecord.readText(data['hostUserId']) ?? AppStrings.emptyValue,
      hostName: UserRecord.readText(data['hostName']) ?? AppStrings.emptyValue,
      phone: UserRecord.formatPhone(
        UserRecord.readText(data['hostCountryCode']),
        UserRecord.readText(data['hostPhoneNumber']),
      ),
      date:
          UserRecord.readDate(data[createdAtField]) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      callCount: count(callCountField),
      callSeconds: count(callDurationField),
      amountEarned: amount(callEarningsField),
      surgeEarnings: amount('surgeEarnings'),
      adminCreditAmount: amount('adminCreditAmount'),
      adminDebitAmount: amount('adminDebitAmount'),
      bonusAmount: amount('bonusAmount'),
      totalAmount: amount(totalAmountField),
      status: isPaid ? WithdrawalStatus.success : WithdrawalStatus.pending,
      paidOn: UserRecord.readDate(data[paidAtField]),
      appliedTdsPercent: isPaid && tdsPercent is num
          ? tdsPercent.round()
          : null,
      paidTdsAmount: isPaid ? paidAmount('tdsAmount') : null,
      paidReceivableAmount: isPaid ? paidAmount('receivableAmount') : null,
      bankAccount: isPaid
          ? PayoutBankAccount.fromMap(data['bankAccount'])
          : null,
    );
  }

  static const String collection = 'hostPayouts';
  static const String hostIdField = 'hostId';
  static const String statusField = 'status';
  static const String withdrawIdField = 'withdrawId';
  static const String callCountField = 'callCount';
  static const String callDurationField = 'callDurationSeconds';
  static const String callEarningsField = 'callEarnings';
  static const String totalAmountField = 'totalAmount';
  static const String createdAtField = 'createdAt';
  static const String paidAtField = 'paidAt';
  static const String tdsPercentField = 'tdsPercent';
  static const String pendingPayoutIdField = 'pendingPayoutId';
  static const String pendingStatus = 'pending';
  static const String successStatus = 'success';

  static const int _visibleDigits = 4;
  static const int _secondsPerMinute = 60;

  final String id;
  final String withdrawId;
  final String hostId;
  final String hostUserId;
  final String hostName;
  final String phone;
  final DateTime date;
  final int callCount;
  final int callSeconds;
  final double amountEarned;
  final double surgeEarnings;
  final double adminCreditAmount;
  final double adminDebitAmount;
  final double bonusAmount;
  final double totalAmount;
  final WithdrawalStatus status;
  final DateTime? paidOn;
  final int? appliedTdsPercent;
  final double? paidTdsAmount;
  final double? paidReceivableAmount;
  final PayoutBankAccount? bankAccount;

  String get initials => NameFormatter.initials(hostName);

  int get avatarIndex =>
      hostId.codeUnits.fold(0, (total, unit) => total + unit);

  int get callMinutes => (callSeconds / _secondsPerMinute).round();

  bool get isPending => status == WithdrawalStatus.pending;

  bool get hasBankAccount => bankAccount != null;

  DateTime get settledDate => paidOn ?? date;

  double get hostCredit =>
      NumberFormatter.roundAmount(totalAmount - amountEarned);

  double tdsAmount(int percent) =>
      paidTdsAmount ?? NumberFormatter.roundAmount(totalAmount * percent / 100);

  double receivableAmount(int percent) =>
      paidReceivableAmount ??
      NumberFormatter.roundAmount(totalAmount - tdsAmount(percent));

  String get accountHolderName =>
      bankAccount?.accountHolderName ?? AppStrings.emptyValue;

  String get branchName => bankAccount?.branchName ?? AppStrings.emptyValue;

  String get accountNumber =>
      bankAccount?.accountNumber ?? AppStrings.emptyValue;

  String get ifscCode => bankAccount?.ifscCode ?? AppStrings.emptyValue;

  String get accountLastDigits => accountNumber.length <= _visibleDigits
      ? accountNumber
      : accountNumber.substring(accountNumber.length - _visibleDigits);

  Withdrawal withBankAccount(PayoutBankAccount? account) =>
      _copy(bankAccount: account);

  Withdrawal markedPaid(PayoutReceipt receipt, DateTime paidOn) => _copy(
    status: WithdrawalStatus.success,
    totalAmount: receipt.totalAmount,
    paidOn: paidOn,
    appliedTdsPercent: receipt.tdsPercent,
    paidTdsAmount: receipt.tdsAmount,
    paidReceivableAmount: receipt.receivableAmount,
  );

  Withdrawal _copy({
    WithdrawalStatus? status,
    double? totalAmount,
    DateTime? paidOn,
    int? appliedTdsPercent,
    double? paidTdsAmount,
    double? paidReceivableAmount,
    PayoutBankAccount? bankAccount,
  }) {
    return Withdrawal(
      id: id,
      withdrawId: withdrawId,
      hostId: hostId,
      hostUserId: hostUserId,
      hostName: hostName,
      phone: phone,
      date: date,
      callCount: callCount,
      callSeconds: callSeconds,
      amountEarned: amountEarned,
      surgeEarnings: surgeEarnings,
      adminCreditAmount: adminCreditAmount,
      adminDebitAmount: adminDebitAmount,
      bonusAmount: bonusAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paidOn: paidOn ?? this.paidOn,
      appliedTdsPercent: appliedTdsPercent ?? this.appliedTdsPercent,
      paidTdsAmount: paidTdsAmount ?? this.paidTdsAmount,
      paidReceivableAmount: paidReceivableAmount ?? this.paidReceivableAmount,
      bankAccount: bankAccount ?? this.bankAccount,
    );
  }
}
