import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';

class UserRecord {
  const UserRecord({
    required this.id,
    this.userID,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.userName,
    this.countryCode,
    this.phoneNumber,
    this.walletBalance = 0,
    this.adminCredit = 0,
    this.adminDebit = 0,
    this.isBlocked = false,
    this.isDeleted = false,
    this.isDeletedByAdmin = false,
    this.isActive = false,
    this.hostDetails = const {},
    this.submittedImageUrl,
    this.avatarApprovedAt,
    this.avatarApprovedBy,
    this.welcomeBonusClaimedAt,
  });

  factory UserRecord.fromDocument(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    final updatedAt = data['updatedAt'];
    final walletBalance = data['walletBalance'];
    final hostDetails = data['hostDetails'];
    final walletSources = data[walletSourcesField];
    num source(String field) {
      final amount = walletSources is Map ? walletSources[field] : null;
      return amount is num ? amount : 0;
    }

    return UserRecord(
      id: id,
      userID: readText(data['userID']),
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
      name: readText(data['name']),
      userName: readText(data['userName']),
      countryCode: readText(data['countryCode']),
      phoneNumber: readText(data['phoneNumber']),
      walletBalance: walletBalance is num ? walletBalance : 0,
      adminCredit: source(adminCreditField),
      adminDebit: source(adminDebitField),
      isBlocked: data['isAccountBlocked'] == true,
      isDeleted: data['isAccountDeleted'] == true,
      isDeletedByAdmin: data[deletedByField] == deletedByAdmin,
      isActive: data['isActive'] == true,
      hostDetails: hostDetails is Map<String, dynamic> ? hostDetails : const {},
      submittedImageUrl: readText(data[submittedImageField]),
      avatarApprovedAt: readDate(data[avatarApprovedAtField]),
      avatarApprovedBy: readText(data[avatarApprovedByField]),
      welcomeBonusClaimedAt: readDate(data[welcomeBonusClaimedAtField]),
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
  static const String isAvatarField = 'isAvathar';
  static const String avatarStatusField = 'avatharStatus';
  static const String avatarImageField = 'avatharImage';
  static const String submittedImageField = 'submitedImageUrl';
  static const String avatarSubmitted = 'submited';
  static const String avatarApprovedAtField = 'avatarApprovedAt';
  static const String avatarApprovedByField = 'avatarApprovedBy';
  static const String hostApprovedAtField = 'approvedAt';
  static const String hostApprovedByField = 'approvedBy';
  static const String deletedByField = 'deletedBy';
  static const String deletedByAdmin = 'admin';
  static const String walletBalanceField = 'walletBalance';
  static const String walletSourcesField = 'walletSources';
  static const String adminCreditField = 'adminCredit';
  static const String adminDebitField = 'adminDebit';
  static const String bonusField = 'bonus';
  static const String deletedAtField = 'deletedAt';
  static const String welcomeBonusClaimedAtField = 'welcomeBonusClaimedAt';
  static const String welcomeBonusAmountField = 'welcomeBonusAmount';
  static const Duration _newAccountWindow = Duration(days: 7);
  static const int _nationalNumberLength = 10;
  static const int _nationalNumberGroup = 5;

  final String id;
  final String? userID;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? name;
  final String? userName;
  final String? countryCode;
  final String? phoneNumber;
  final num walletBalance;
  final num adminCredit;
  final num adminDebit;
  final bool isBlocked;
  final bool isDeleted;
  final bool isDeletedByAdmin;
  final bool isActive;
  final Map<String, dynamic> hostDetails;
  final String? submittedImageUrl;
  final DateTime? avatarApprovedAt;
  final String? avatarApprovedBy;
  final DateTime? welcomeBonusClaimedAt;

  static String? readText(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  static DateTime? readDate(Object? value) =>
      value is Timestamp ? value.toDate() : null;

  DateTime? get hostApprovedAt => readDate(hostDetails[hostApprovedAtField]);

  String? get hostApprovedBy => readText(hostDetails[hostApprovedByField]);

  String? get hostUserName =>
      readText(hostDetails['userName']) ?? userName ?? name;

  bool get hasValidSubmittedImage {
    final uri = Uri.tryParse(submittedImageUrl ?? '');
    return uri != null &&
        (uri.isScheme('https') || uri.isScheme('http')) &&
        uri.host.isNotEmpty;
  }

  static Map<String, Object?>? profilePhotoDecision(
    Map<String, dynamic> data, {
    required bool approved,
    required String reviewedUrl,
    required String adminUid,
  }) {
    final isStillPending =
        data[isAvatarField] == false &&
        data[avatarStatusField] == avatarSubmitted &&
        readText(data[submittedImageField]) == reviewedUrl;
    if (!isStillPending) return null;

    return {
      avatarStatusField: approved ? documentApproved : documentRejected,
      if (approved) avatarImageField: reviewedUrl,
      if (approved && data[avatarApprovedAtField] == null) ...{
        avatarApprovedAtField: FieldValue.serverTimestamp(),
        avatarApprovedByField: adminUid,
      },
    };
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
    required String adminUid,
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
      if (approved && details[hostApprovedAtField] == null) ...{
        'hostDetails.$hostApprovedAtField': FieldValue.serverTimestamp(),
        'hostDetails.$hostApprovedByField': adminUid,
      },
    };
  }

  static Map<String, Object?>? walletAdjustment(
    Map<String, dynamic> data, {
    required bool isCredit,
    required int amount,
  }) {
    final balance = data[walletBalanceField];
    if (!isCredit && amount > (balance is num ? balance : 0)) return null;

    final source = isCredit ? adminCreditField : adminDebitField;
    return {
      walletBalanceField: FieldValue.increment(isCredit ? amount : -amount),
      '$walletSourcesField.$source': FieldValue.increment(amount),
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

  String get userIDLabel => userID ?? AppStrings.emptyValue;

  String get createdDateLabel {
    final date = createdAt;
    return date == null ? AppStrings.emptyValue : DateFormatter.short(date);
  }

  String get phoneLabel => formatPhone(countryCode, phoneNumber);

  static String formatPhone(String? countryCode, String? number) {
    if (number == null) return AppStrings.emptyValue;
    final grouped = number.length == _nationalNumberLength
        ? '${number.substring(0, _nationalNumberGroup)} '
              '${number.substring(_nationalNumberGroup)}'
        : number;
    return [?countryCode, grouped].join(' ');
  }

  static String formatFullPhone(String phone) {
    final fields = phoneFields(phone);
    if (fields == null) return phone;
    return formatPhone(
      fields['countryCode'] as String?,
      fields['phoneNumber'] as String?,
    );
  }

  int get avatarIndex => id.codeUnits.fold(0, (total, unit) => total + unit);

  static DateTime get newAccountCutoff =>
      DateTime.now().subtract(_newAccountWindow);

  bool get isNewAccount {
    final date = createdAt;
    return date != null && DateTime.now().difference(date) <= _newAccountWindow;
  }
}
