import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';

class UserRecord {
  const UserRecord({
    required this.id,
    this.createdAt,
    this.name,
    this.userName,
    this.countryCode,
    this.phoneNumber,
    this.walletBalance = 0,
    this.isBlocked = false,
    this.isDeleted = false,
    this.isDeletedByAdmin = false,
    this.isActive = false,
    this.hostDetails = const {},
  });

  factory UserRecord.fromDocument(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    final walletBalance = data['walletBalance'];
    final hostDetails = data['hostDetails'];

    return UserRecord(
      id: id,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      name: readText(data['name']),
      userName: readText(data['userName']),
      countryCode: readText(data['countryCode']),
      phoneNumber: readText(data['phoneNumber']),
      walletBalance: walletBalance is num ? walletBalance : 0,
      isBlocked: data['isAccountBlocked'] == true,
      isDeleted: data['isAccountDeleted'] == true,
      isDeletedByAdmin: data[deletedByField] == deletedByAdmin,
      isActive: data['isActive'] == true,
      hostDetails: hostDetails is Map<String, dynamic> ? hostDetails : const {},
    );
  }

  static const String documentSubmitted = 'submitted';
  static const String documentApproved = 'approved';
  static const String documentRejected = 'rejected';
  static const String documentStatusField = 'documentStatus';
  static const String aadhaarFrontField = 'aadharFrontPreview';
  static const String aadhaarBackField = 'aadharBackPreview';
  static const String selfieField = 'selfiPreview';
  static const List<String> hostDocumentFields = [
    aadhaarFrontField,
    aadhaarBackField,
    selfieField,
  ];
  static const String deletedByField = 'deletedBy';
  static const String deletedByAdmin = 'admin';
  static const Duration _newAccountWindow = Duration(days: 7);
  static const int _nationalNumberLength = 10;
  static const int _nationalNumberGroup = 5;

  final String id;
  final DateTime? createdAt;
  final String? name;
  final String? userName;
  final String? countryCode;
  final String? phoneNumber;
  final num walletBalance;
  final bool isBlocked;
  final bool isDeleted;
  final bool isDeletedByAdmin;
  final bool isActive;
  final Map<String, dynamic> hostDetails;

  static String? readText(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  static Map<String, Object?>? hostDocumentReview(
    Map<String, dynamic> data, {
    required String document,
    required String status,
  }) {
    final details = data['hostDetails'];
    if (details is! Map) return null;

    Object? statusOf(String field) {
      final entry = details[field];
      return entry is Map ? entry[documentStatusField] : null;
    }

    if (statusOf(document) != documentSubmitted) return null;

    return {'hostDetails.$document.$documentStatusField': status};
  }

  static Map<String, Object?>? hostRequestDecision(
    Map<String, dynamic> data, {
    required bool approved,
  }) {
    final details = data['hostDetails'];
    if (details is! Map || details['hostStatus'] != documentSubmitted) {
      return null;
    }

    final allDocumentsApproved = hostDocumentFields.every((field) {
      final entry = details[field];
      return entry is Map && entry[documentStatusField] == documentApproved;
    });
    if (!allDocumentsApproved) return null;

    return {
      'hostDetails.hostStatus': approved ? documentApproved : documentRejected,
      if (approved && data['role'] == 'user') 'role': 'host',
    };
  }

  static Map<String, Object?>? phoneFields(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final digits = cleaned.replaceAll('+', '');
    if (digits.length < _nationalNumberLength) return null;

    final codeLength = digits.length - _nationalNumberLength;
    if (!cleaned.startsWith('+') || codeLength == 0) {
      return {'phoneNumber': digits};
    }
    return {
      'countryCode': '+${digits.substring(0, codeLength)}',
      'phoneNumber': digits.substring(codeLength),
    };
  }

  String get createdDateLabel {
    final date = createdAt;
    return date == null ? AppStrings.emptyValue : DateFormatter.short(date);
  }

  String get phoneLabel {
    final number = phoneNumber;
    if (number == null) return AppStrings.emptyValue;
    final grouped = number.length == _nationalNumberLength
        ? '${number.substring(0, _nationalNumberGroup)} '
              '${number.substring(_nationalNumberGroup)}'
        : number;
    return [?countryCode, grouped].join(' ');
  }

  int get avatarIndex => id.codeUnits.fold(0, (total, unit) => total + unit);

  bool get isNewAccount {
    final date = createdAt;
    return date != null && DateTime.now().difference(date) <= _newAccountWindow;
  }
}
