import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';

class BankAccountRecord {
  const BankAccountRecord({
    required this.id,
    this.accountHolderName,
    this.accountNumber,
    this.branchName,
    this.ifscCode,
    this.panNumber,
    this.status,
    this.createdDate,
    this.updatedAt,
    this.adminApprovedAt,
    this.adminApprovedBy,
  });

  factory BankAccountRecord.fromDocument(
    String id,
    Map<String, dynamic> data,
  ) => BankAccountRecord(
    id: id,
    accountHolderName: UserRecord.readText(data[accountHolderNameField]),
    accountNumber: UserRecord.readText(data[accountNumberField]),
    branchName: UserRecord.readText(data[branchNameField]),
    ifscCode: UserRecord.readText(data[ifscCodeField]),
    panNumber: UserRecord.readText(data[panNumberField]),
    status: UserRecord.readText(data[statusField]),
    createdDate: UserRecord.readDate(data['createdDate']),
    updatedAt: UserRecord.readDate(data['updatedAt']),
    adminApprovedAt: UserRecord.readDate(data[adminApprovedAtField]),
    adminApprovedBy: UserRecord.readText(data[adminApprovedByField]),
  );

  static const String collection = 'bankAccounts';
  static const String statusField = 'bankAccountStatus';
  static const String accountHolderNameField = 'accountHolderName';
  static const String branchNameField = 'branchName';
  static const String accountNumberField = 'accountNo';
  static const String ifscCodeField = 'ifscCode';
  static const String panNumberField = 'panNumber';
  static const String updatedAtField = 'updatedAt';
  static const String adminApprovedAtField = 'adminApprovedAt';
  static const String adminApprovedByField = 'adminApprovedBy';

  final String id;
  final String? accountHolderName;
  final String? accountNumber;
  final String? branchName;
  final String? ifscCode;
  final String? panNumber;
  final String? status;
  final DateTime? createdDate;
  final DateTime? updatedAt;
  final DateTime? adminApprovedAt;
  final String? adminApprovedBy;

  bool hasSameDetails(BankAccountRecord other) =>
      accountHolderName == other.accountHolderName &&
      branchName == other.branchName &&
      accountNumber == other.accountNumber &&
      ifscCode == other.ifscCode &&
      (panNumber ?? '') == (other.panNumber ?? '');

  BankAccountRecord copyWith({
    String? accountHolderName,
    String? accountNumber,
    String? branchName,
    String? ifscCode,
    String? panNumber,
    DateTime? updatedAt,
  }) => BankAccountRecord(
    id: id,
    accountHolderName: accountHolderName ?? this.accountHolderName,
    accountNumber: accountNumber ?? this.accountNumber,
    branchName: branchName ?? this.branchName,
    ifscCode: ifscCode ?? this.ifscCode,
    panNumber: panNumber ?? this.panNumber,
    status: status,
    createdDate: createdDate,
    updatedAt: updatedAt ?? this.updatedAt,
    adminApprovedAt: adminApprovedAt,
    adminApprovedBy: adminApprovedBy,
  );

  static Map<String, Object?>? edit(
    Map<String, dynamic> data, {
    required BankAccountRecord reviewed,
    required BankAccountRecord edited,
  }) {
    final stored = BankAccountRecord.fromDocument(reviewed.id, data);
    if (!stored.hasSameDetails(reviewed)) return null;

    return {
      if (edited.accountHolderName != stored.accountHolderName)
        accountHolderNameField: edited.accountHolderName,
      if (edited.branchName != stored.branchName)
        branchNameField: edited.branchName,
      if (edited.accountNumber != stored.accountNumber)
        accountNumberField: edited.accountNumber,
      if (edited.ifscCode != stored.ifscCode) ifscCodeField: edited.ifscCode,
      if ((edited.panNumber ?? '') != (stored.panNumber ?? ''))
        panNumberField: edited.panNumber,
    };
  }

  static Map<String, Object?>? decision(
    Map<String, dynamic> data, {
    required bool approved,
    required String reviewedAccountNumber,
    required String reviewedIfscCode,
    required String adminUid,
  }) {
    final isStillPending =
        data[statusField] == UserRecord.documentSubmitted &&
        UserRecord.readText(data[accountNumberField]) ==
            reviewedAccountNumber &&
        UserRecord.readText(data[ifscCodeField]) == reviewedIfscCode;
    if (!isStillPending) return null;

    return {
      statusField: approved
          ? UserRecord.documentApproved
          : UserRecord.documentRejected,
      if (approved) ...{
        adminApprovedAtField: FieldValue.serverTimestamp(),
        adminApprovedByField: adminUid,
      },
    };
  }
}
