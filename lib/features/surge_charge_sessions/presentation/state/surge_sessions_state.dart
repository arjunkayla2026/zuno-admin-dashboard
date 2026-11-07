import 'package:zuno_admin_dashboard/features/surge_charge_sessions/data/models/surge_session.dart';

class SurgeSessionsState {
  const SurgeSessionsState({required this.sessions});

  final List<SurgeSession> sessions;

  int get nextId => sessions.fold(0, (max, s) => s.id > max ? s.id : max) + 1;

  SurgeSessionsState copyWith({List<SurgeSession>? sessions}) {
    return SurgeSessionsState(sessions: sessions ?? this.sessions);
  }
}
