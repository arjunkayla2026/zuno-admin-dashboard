import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/state/calls_state.dart';

abstract final class CallLogLabels {
  static String type(CallLogType type) => switch (type) {
    CallLogType.audio => AppStrings.audio,
    CallLogType.video => AppStrings.video,
  };

  static (String, AppStatus) status(CallLog call) {
    if (call.isLowBalance) return (AppStrings.lowBalance, AppStatus.pending);
    return switch (call.status) {
      CallLogStatus.ringing => (AppStrings.incoming, AppStatus.pending),
      CallLogStatus.ongoing => (AppStrings.ongoing, AppStatus.active),
      CallLogStatus.completed => (AppStrings.completed, AppStatus.active),
      CallLogStatus.busy => (AppStrings.busy, AppStatus.pending),
      CallLogStatus.rejected => (AppStrings.rejected, AppStatus.error),
      CallLogStatus.missed => (AppStrings.notAnswered, AppStatus.pending),
      CallLogStatus.cancelled => (AppStrings.missed, AppStatus.inactive),
      CallLogStatus.failed => (AppStrings.failed, AppStatus.error),
    };
  }

  static String endedBy(CallLog call) {
    if (call.endedForLowBalance) {
      return AppStrings.endedByReason(
        AppStrings.userRole,
        AppStrings.lowBalanceReason,
      );
    }
    final party = switch (call.endedBy) {
      CallEndedBy.user => AppStrings.userRole,
      CallEndedBy.host => AppStrings.hostRole,
      CallEndedBy.system => AppStrings.systemRole,
      null => null,
    };
    if (party == null) return AppStrings.emptyValue;
    // A plain hang-up (`participantLeft` / `endedByParticipant`) needs no
    // reason; every other ending says why.
    final reason = switch (call.endReason) {
      CallLog.cancelledByCustomerReason => AppStrings.cancelledReason,
      CallLog.rejectedByHostReason => AppStrings.rejectedReason,
      CallLog.noAnswerReason => AppStrings.noAnswerReason,
      CallLog.hostUnreachableReason => AppStrings.hostUnreachableReason,
      CallLog.connectionFailedReason => AppStrings.connectionFailedReason,
      CallLog.webhookMissingReason => AppStrings.connectionLostReason,
      CallLog.maxDurationReason => AppStrings.timeLimitReason,
      _ => null,
    };
    return reason == null ? party : AppStrings.endedByReason(party, reason);
  }

  static String statusFilter(CallStatusFilter filter) => switch (filter) {
    CallStatusFilter.incoming => AppStrings.incomingCalls,
    CallStatusFilter.ongoing => AppStrings.ongoingCalls,
    CallStatusFilter.completed => AppStrings.completedCalls,
    CallStatusFilter.busy => AppStrings.busyCalls,
    CallStatusFilter.rejected => AppStrings.rejectedCalls,
    CallStatusFilter.notAnswered => AppStrings.notAnsweredCalls,
    CallStatusFilter.lowBalance => AppStrings.lowBalanceCalls,
    CallStatusFilter.missed => AppStrings.missedCalls,
  };

  static String typeFilter(CallTypeOption type) => switch (type) {
    CallTypeOption.all => AppStrings.callsType,
    CallTypeOption.audio => AppStrings.audioCall,
    CallTypeOption.video => AppStrings.videoCall,
  };
}
