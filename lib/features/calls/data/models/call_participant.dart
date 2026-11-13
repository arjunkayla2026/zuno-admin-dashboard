import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';

class CallParticipant {
  const CallParticipant.user(this.id) : field = CallLog.customerIdField;

  const CallParticipant.host(this.id) : field = CallLog.hostIdField;

  final String field;
  final String id;
}
