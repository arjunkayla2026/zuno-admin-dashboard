import 'package:zuno_admin_dashboard/features/reports/data/models/user_report.dart';

class ReportsQuery {
  const ReportsQuery({
    this.term,
    this.from,
    this.until,
    this.type,
    this.reporterRole,
  });

  final String? term;
  final DateTime? from;
  final DateTime? until;
  final ReportType? type;
  final ReportPartyRole? reporterRole;

  ReportsQuery get withoutTerm => ReportsQuery(
    from: from,
    until: until,
    type: type,
    reporterRole: reporterRole,
  );

  bool includes(UserReport report) =>
      (from == null || !report.date.isBefore(from!)) &&
      (until == null || report.date.isBefore(until!)) &&
      (type == null || report.type == type) &&
      (reporterRole == null || report.reportedBy.role == reporterRole);

  @override
  bool operator ==(Object other) =>
      other is ReportsQuery &&
      other.term == term &&
      other.from == from &&
      other.until == until &&
      other.type == type &&
      other.reporterRole == reporterRole;

  @override
  int get hashCode => Object.hash(term, from, until, type, reporterRole);
}
