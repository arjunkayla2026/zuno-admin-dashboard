import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/host_request.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/host_profile_labels.dart';

abstract final class HostRequestLabels {
  static (String, AppStatus) status(HostRequestStatus status) =>
      switch (status) {
        HostRequestStatus.pending => (AppStrings.pending, AppStatus.pending),
        HostRequestStatus.approved => (AppStrings.approved, AppStatus.active),
        HostRequestStatus.rejected => (AppStrings.rejected, AppStatus.error),
      };

  static String languages(HostRequest request) =>
      HostProfileLabels.languageList(request.languages);

  static String document(HostDocumentType type) => switch (type) {
    HostDocumentType.aadhaarFront => AppStrings.aadhaarFront,
    HostDocumentType.aadhaarBack => AppStrings.aadhaarBack,
    HostDocumentType.selfie => AppStrings.selfie,
  };

  static String dateOfBirth(HostRequest request) {
    final date = request.dateOfBirth;
    return date == null ? AppStrings.emptyValue : DateFormatter.short(date);
  }

  static String gender(HostRequest request) {
    final gender = request.gender;
    return gender == null
        ? AppStrings.emptyValue
        : HostProfileLabels.gender(gender);
  }
}
