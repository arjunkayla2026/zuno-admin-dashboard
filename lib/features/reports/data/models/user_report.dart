import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/report_search.dart';

enum ReportPartyRole {
  user('user'),
  host('host');

  const ReportPartyRole(this.value);

  final String value;

  ReportPartyRole get peer => this == user ? host : user;

  static ReportPartyRole fromValue(Object? value) =>
      value == host.value ? host : user;
}

enum ReportType {
  askingPersonalDetails('askingPersonalDetails'),
  offensiveLanguage('offensiveLanguage'),
  inappropriateBehavior('inappropriateBehavior'),
  requestingPersonalDetails('requestingPersonalDetails'),
  notResponding('notResponding'),
  moneyRequests('moneyRequests'),
  other('other');

  const ReportType(this.value);

  final String value;

  static ReportType fromValue(Object? value) {
    for (final type in values) {
      if (type.value == value) return type;
    }
    return other;
  }
}

class ReportParty {
  const ReportParty({
    required this.id,
    required this.name,
    required this.displayId,
    required this.role,
    this.phone,
  });

  final String id;
  final String name;
  final String displayId;
  final ReportPartyRole role;
  final String? phone;

  String get initials => NameFormatter.initials(name);

  String get detailsLabel => [
    displayId,
    if (phone case final phone?) UserRecord.formatFullPhone(phone),
  ].join(AppStrings.metaSeparator);

  int get avatarIndex => id.codeUnits.fold(0, (total, unit) => total + unit);
}

class UserReport {
  const UserReport({
    required this.id,
    required this.date,
    required this.reportedBy,
    required this.reported,
    required this.type,
    this.receivedTotal,
    this.callId,
    this.details,
    this.searchValues = const {},
  });

  factory UserReport.fromDocument(String id, Map<String, dynamic> data) {
    String? text(String field) => UserRecord.readText(data[field]);

    ReportParty party({
      required ReportPartyRole role,
      required String idField,
      required String nameField,
      required String phoneField,
    }) {
      final isUser = role == ReportPartyRole.user;
      final partyId =
          text(idField) ?? text(isUser ? customerIdField : hostIdField) ?? '';
      return ReportParty(
        id: partyId,
        name:
            text(nameField) ??
            text(isUser ? customerNameField : hostNameField) ??
            AppStrings.emptyValue,
        displayId:
            text(isUser ? customerUserIdField : hostUserIdField) ?? partyId,
        role: role,
        phone: text(phoneField),
      );
    }

    final reporterRole = data[reporterRoleField] == null
        ? (text(reportedByField) == text(hostIdField)
              ? ReportPartyRole.host
              : ReportPartyRole.user)
        : ReportPartyRole.fromValue(data[reporterRoleField]);
    return UserReport(
      id: id,
      date:
          UserRecord.readDate(data[reportedAtField]) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      reportedBy: party(
        role: reporterRole,
        idField: reportedByField,
        nameField: reportedByNameField,
        phoneField: reportedByPhoneField,
      ),
      reported: party(
        role: reporterRole.peer,
        idField: reportedField,
        nameField: reportedNameField,
        phoneField: reportedPhoneField,
      ),
      type: ReportType.fromValue(data[reportTypeField]),
      callId: text(callIdField),
      details: text(reportDetailsField),
      searchValues: {
        for (final field in ReportSearch.fields)
          if (data[field] case final String value) field: value,
      },
    );
  }

  static const String collection = 'reports';
  static const String reportedAtField = 'reportedAt';
  static const String reportTypeField = 'reportType';
  static const String reporterRoleField = 'reporterRole';
  static const String reportedByField = 'reportedBy';
  static const String reportedField = 'reported';
  static const String reportedByNameField = 'reportedByName';
  static const String reportedNameField = 'reportedName';
  static const String reportedByPhoneField = 'reportedByPhone';
  static const String reportedPhoneField = 'reportedPhone';
  static const String reportedUsersCollection = 'reportedUsers';
  static const String totalReceivedCountField = 'totalReceivedCount';
  static const String reportDetailsField = 'reportDetails';
  static const String callIdField = 'callId';
  static const String customerIdField = 'customerId';
  static const String hostIdField = 'hostId';
  static const String customerNameField = 'customerName';
  static const String hostNameField = 'hostName';
  static const String customerUserIdField = 'customerUserId';
  static const String hostUserIdField = 'hostUserId';

  final String id;
  final DateTime date;
  final ReportParty reportedBy;
  final ReportParty reported;
  final ReportType type;
  final int? receivedTotal;
  final String? callId;
  final String? details;
  final Map<String, String> searchValues;

  UserReport withReceivedTotal(int? total) => UserReport(
    id: id,
    date: date,
    reportedBy: reportedBy,
    reported: reported,
    type: type,
    receivedTotal: total,
    callId: callId,
    details: details,
    searchValues: searchValues,
  );
}
