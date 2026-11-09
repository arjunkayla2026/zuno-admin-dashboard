import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
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
}
