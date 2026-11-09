import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/payout_request.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';

abstract final class PayoutRequestLabels {
  static (String, AppStatus) status(PayoutRequestStatus status) =>
      switch (status) {
        PayoutRequestStatus.pending => (AppStrings.pending, AppStatus.pending),
        PayoutRequestStatus.accepted => (AppStrings.accepted, AppStatus.active),
        PayoutRequestStatus.rejected => (AppStrings.rejected, AppStatus.error),
      };

  static String hostStatus(HostStatus status) => switch (status) {
    HostStatus.active => AppStrings.active,
    HostStatus.inactive => AppStrings.inactive,
    HostStatus.blocked => AppStrings.blocked,
    HostStatus.deletedByAdmin => AppStrings.deletedByAdmin,
    HostStatus.deletedByUser => AppStrings.deletedByUser,
  };
}
