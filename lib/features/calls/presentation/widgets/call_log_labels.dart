import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';

abstract final class CallLogLabels {
  static String type(CallLogType type) => switch (type) {
    CallLogType.audio => AppStrings.audio,
    CallLogType.video => AppStrings.video,
  };

  static (String, AppStatus) status(CallLogStatus status) => switch (status) {
    CallLogStatus.completed => (AppStrings.completed, AppStatus.active),
    CallLogStatus.busy => (AppStrings.busy, AppStatus.pending),
    CallLogStatus.rejected => (AppStrings.rejected, AppStatus.error),
    CallLogStatus.notAnswered => (AppStrings.notAnswered, AppStatus.pending),
    CallLogStatus.lowBalance => (AppStrings.lowBalance, AppStatus.pending),
    CallLogStatus.missed => (AppStrings.missed, AppStatus.inactive),
  };
}
