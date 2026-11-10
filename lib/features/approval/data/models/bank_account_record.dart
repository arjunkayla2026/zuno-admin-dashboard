import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';

class BankAccountRecord {
  const BankAccountRecord({
    required this.id,
    this.accountHolderName,
    this.accountNumber,
    this.branchName,
    this.ifscCode,
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
    accountHolderName: UserRecord.readText(data['accountHolderName']),
    accountNumber: UserRecord.readText(data[accountNumberField]),
    branchName: UserRecord.readText(data['branchName']),
    ifscCode: UserRecord.readText(data[ifscCodeField]),
    createdDate: UserRecord.readDate(data['createdDate']),
    updatedAt: UserRecord.readDate(data['updatedAt']),
    adminApprovedAt: UserRecord.readDate(data[adminApprovedAtField]),
    adminApprovedBy: UserRecord.readText(data[adminApprovedByField]),
  );

  static const String statusField = 'bankAccountStatus';
  static const String accountNumberField = 'accountNo';
  static const String ifscCodeField = 'ifscCode';
  static const String adminApprovedAtField = 'adminApprovedAt';
  static const String adminApprovedByField = 'adminApprovedBy';

  final String id;
  final String? accountHolderName;
  final String? accountNumber;
  final String? branchName;
  final String? ifscCode;
  final DateTime? createdDate;
  final DateTime? updatedAt;
  final DateTime? adminApprovedAt;
  final String? adminApprovedBy;

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
