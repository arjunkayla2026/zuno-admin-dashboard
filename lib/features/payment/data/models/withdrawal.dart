import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';

/// [forfeited] also covers any status the dashboard does not recognise, so an
/// unexpected payout can never be listed or acted on as open.
enum WithdrawalStatus { open, pending, success, forfeited }

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
    this.phoneNumber,
    this.callCount = 0,
    this.callSeconds = 0,
    this.amountEarned = 0,
    this.surgeEarnings = 0,
    this.adminCreditAmount = 0,
    this.adminDebitAmount = 0,
    this.bonusAmount = 0,
    this.totalAmount = 0,
    this.status = WithdrawalStatus.open,
    this.periodStart,
    this.periodEnd,
    this.pendingOn,
    this.pendingByName,
    this.paidOn,
    this.paidBy,
    this.paidByName,
    this.appliedTdsPercent,
    this.paidTdsAmount,
    this.paidReceivableAmount,
    this.bankAccount,
  });

  factory Withdrawal.fromDocument(String id, Map<String, dynamic> data) {
    final status = switch (data[statusField]) {
      openStatus => WithdrawalStatus.open,
      pendingStatus => WithdrawalStatus.pending,
      successStatus => WithdrawalStatus.success,
      _ => WithdrawalStatus.forfeited,
    };
    final isOpen = status == WithdrawalStatus.open;
    final isPaid = status == WithdrawalStatus.success;
    final withdrawable = data[withdrawableField];
    final amounts = isOpen
        ? (withdrawable is Map ? withdrawable : const {})
        : data;

    int count(String field) {
      final value = amounts[field];
      return value is num ? value.round() : 0;
    }

    double amount(String field) {
      final value = amounts[field];
      return value is num ? value.toDouble() : 0;
    }

    double? paidAmount(String field) {
      final value = data[field];
      return isPaid && value is num ? value.toDouble() : null;
    }

    final tdsPercent = data[tdsPercentField];
    return Withdrawal(
      id: id,
      withdrawId: UserRecord.readText(data[withdrawIdField]) ?? id,
      hostId: UserRecord.readText(data[hostIdField]) ?? '',
      hostUserId:
          UserRecord.readText(data[hostUserIdField]) ?? AppStrings.emptyValue,
      hostName:
          UserRecord.readText(data[hostNameField]) ?? AppStrings.emptyValue,
      phone: UserRecord.formatPhone(
        UserRecord.readText(data['hostCountryCode']),
        UserRecord.readText(data['hostPhoneNumber']),
      ),
      phoneNumber: UserRecord.readText(data['hostPhoneNumber']),
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
      status: status,
      periodStart: _dayOf(data['periodStartDay']),
      periodEnd: _dayOf(
        isOpen ? data['withdrawableThroughDay'] : data['periodEndDay'],
      ),
      pendingOn: UserRecord.readDate(data['pendingAt']),
      pendingByName: UserRecord.readText(data['pendingByName']),
      paidOn: UserRecord.readDate(data[paidAtField]),
      paidBy: UserRecord.readText(data['paidBy']),
      paidByName: UserRecord.readText(data['paidByName']),
      appliedTdsPercent: isPaid && tdsPercent is num
          ? tdsPercent.round()
          : null,
      paidTdsAmount: paidAmount('tdsAmount'),
      paidReceivableAmount: paidAmount('receivableAmount'),
      bankAccount: isPaid
          ? PayoutBankAccount.fromMap(data['bankAccount'])
          : null,
    );
  }

  static const String collection = 'hostPayouts';
  static const String hostIdField = 'hostId';
  static const String hostNameField = 'hostName';
  static const String hostUserIdField = 'hostUserId';
  static const String statusField = 'status';
  static const String withdrawIdField = 'withdrawId';
  static const String withdrawableField = 'withdrawable';
  static const String callCountField = 'callCount';
  static const String callDurationField = 'callDurationSeconds';
  static const String callEarningsField = 'callEarnings';
  static const String totalAmountField = 'totalAmount';
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
  static const String paidAtField = 'paidAt';
  static const String tdsPercentField = 'tdsPercent';
  static const String pendingPayoutIdField = 'pendingPayoutId';
  static const String openStatus = 'open';
  static const String pendingStatus = 'pending';
  static const String successStatus = 'success';
  static const List<String> listedStatuses = [
    openStatus,
    pendingStatus,
    successStatus,
  ];

  static String withdrawablePath(String field) => '$withdrawableField.$field';

  /// Shown in a host's withdrawal history: open, pending and paid records,
  /// not ones forfeited when the account was deleted.
  bool get isListed => status != WithdrawalStatus.forfeited;

  static DateTime? _dayOf(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  static const int _visibleDigits = 4;
  static const int _secondsPerMinute = 60;

  final String id;
  final String withdrawId;
  final String hostId;
  final String hostUserId;
  final String hostName;
  final String phone;
  final String? phoneNumber;
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
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime? pendingOn;
  final String? pendingByName;
  final DateTime? paidOn;
  final String? paidBy;
  final String? paidByName;
  final int? appliedTdsPercent;
  final double? paidTdsAmount;
  final double? paidReceivableAmount;
  final PayoutBankAccount? bankAccount;

  String get initials => NameFormatter.initials(hostName);

  int get avatarIndex =>
      hostId.codeUnits.fold(0, (total, unit) => total + unit);

  int get callMinutes => (callSeconds / _secondsPerMinute).round();

  bool get isOpen => status == WithdrawalStatus.open;

  bool get isPending => status == WithdrawalStatus.pending;

  bool get isPaid => status == WithdrawalStatus.success;

  bool get hasBankAccount => bankAccount != null;

  DateTime get settledDate => paidOn ?? pendingOn ?? date;

  double get hostCredit => totalAmount - amountEarned;

  double tdsAmount(int percent) => paidTdsAmount ?? totalAmount * percent / 100;

  double receivableAmount(int percent) =>
      paidReceivableAmount ?? totalAmount - tdsAmount(percent);

  String get accountHolderName =>
      bankAccount?.accountHolderName ?? AppStrings.emptyValue;

  String get branchName => bankAccount?.branchName ?? AppStrings.emptyValue;

  String get accountNumber =>
      bankAccount?.accountNumber ?? AppStrings.emptyValue;

  String get ifscCode => bankAccount?.ifscCode ?? AppStrings.emptyValue;

  String get accountLastDigits => accountNumber.length <= _visibleDigits
      ? accountNumber
      : accountNumber.substring(accountNumber.length - _visibleDigits);

  String get paidByLabel => switch ((paidByName, paidBy)) {
    (final name?, final uid?) => AppStrings.paidByValue(name, uid),
    (final name?, null) => name,
    (null, final uid?) => uid,
    (null, null) => AppStrings.emptyValue,
  };

  Withdrawal withBankAccount(PayoutBankAccount? account) =>
      _copy(bankAccount: account);

  Withdrawal markedPending(double amount, DateTime pendingOn) => _copy(
    status: WithdrawalStatus.pending,
    totalAmount: amount,
    pendingOn: pendingOn,
  );

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
    DateTime? pendingOn,
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
      phoneNumber: phoneNumber,
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
      periodStart: periodStart,
      periodEnd: periodEnd,
      pendingOn: pendingOn ?? this.pendingOn,
      pendingByName: pendingByName,
      paidOn: paidOn ?? this.paidOn,
      paidBy: paidBy,
      paidByName: paidByName,
      appliedTdsPercent: appliedTdsPercent ?? this.appliedTdsPercent,
      paidTdsAmount: paidTdsAmount ?? this.paidTdsAmount,
      paidReceivableAmount: paidReceivableAmount ?? this.paidReceivableAmount,
      bankAccount: bankAccount ?? this.bankAccount,
    );
  }
}
