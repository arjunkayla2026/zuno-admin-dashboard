import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';

enum ReportPartyRole { user, host }

enum ReportType { fakeProfile, harassment, abusiveLanguage, other }

class ReportParty {
  const ReportParty({
    required this.name,
    required this.id,
    required this.role,
    required this.avatarIndex,
  });

  final String name;
  final String id;
  final ReportPartyRole role;
  final int avatarIndex;

  String get initials => NameFormatter.initials(name);
}

class UserReport {
  const UserReport({
    required this.date,
    required this.reportedBy,
    required this.reported,
    required this.type,
    required this.totalReports,
  });

  final DateTime date;
  final ReportParty reportedBy;
  final ReportParty reported;
  final ReportType type;
  final int totalReports;
}
