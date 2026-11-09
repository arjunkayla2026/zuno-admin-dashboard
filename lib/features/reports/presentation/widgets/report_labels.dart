import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/user_report.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/state/reports_state.dart';

abstract final class ReportLabels {
  static (String, AppStatus) type(ReportType type) => switch (type) {
    ReportType.fakeProfile => (AppStrings.fakeProfile, AppStatus.pending),
    ReportType.harassment => (AppStrings.harassment, AppStatus.error),
    ReportType.abusiveLanguage => (AppStrings.abusiveLanguage, AppStatus.error),
    ReportType.other => (AppStrings.otherReason, AppStatus.inactive),
  };

  static String typeFilter(ReportTypeFilter filter) => switch (filter) {
    ReportTypeFilter.all => AppStrings.allReportTypes,
    ReportTypeFilter.fakeProfile => AppStrings.fakeProfile,
    ReportTypeFilter.harassment => AppStrings.harassment,
    ReportTypeFilter.abusiveLanguage => AppStrings.abusiveLanguage,
    ReportTypeFilter.other => AppStrings.otherReason,
  };

  static String role(ReportPartyRole role) => switch (role) {
    ReportPartyRole.user => AppStrings.userRole,
    ReportPartyRole.host => AppStrings.hostRole,
  };
}
