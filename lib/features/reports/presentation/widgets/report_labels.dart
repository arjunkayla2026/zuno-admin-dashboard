import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/user_report.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/state/reports_state.dart';

abstract final class ReportLabels {
  static (String, AppStatus) type(ReportType type) => switch (type) {
    ReportType.askingPersonalDetails => (
      AppStrings.askingPersonalDetails,
      AppStatus.pending,
    ),
    ReportType.offensiveLanguage => (
      AppStrings.offensiveLanguage,
      AppStatus.error,
    ),
    ReportType.inappropriateBehavior => (
      AppStrings.inappropriateBehavior,
      AppStatus.error,
    ),
    ReportType.requestingPersonalDetails => (
      AppStrings.requestingPersonalDetails,
      AppStatus.pending,
    ),
    ReportType.notResponding => (AppStrings.notResponding, AppStatus.inactive),
    ReportType.moneyRequests => (AppStrings.moneyRequests, AppStatus.error),
    ReportType.other => (AppStrings.otherReason, AppStatus.inactive),
  };

  static String typeFilter(ReportTypeFilter filter) => switch (filter.type) {
    null => AppStrings.allReportTypes,
    final type => ReportLabels.type(type).$1,
  };

  static String reporterFilter(ReporterFilter filter) => switch (filter.role) {
    null => AppStrings.all,
    final role => ReportLabels.role(role),
  };

  static String role(ReportPartyRole role) => switch (role) {
    ReportPartyRole.user => AppStrings.userRole,
    ReportPartyRole.host => AppStrings.hostRole,
  };
}
