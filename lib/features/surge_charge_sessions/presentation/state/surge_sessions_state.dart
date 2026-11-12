import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/data/models/surge_session.dart';

class SurgeSessionsState {
  const SurgeSessionsState({
    this.status = LoadStatus.loading,
    this.sessions = const [],
    this.errorMessage,
    this.saving = false,
  });

  final LoadStatus status;
  final List<SurgeSession> sessions;
  final String? errorMessage;
  final bool saving;

  int get nextId => sessions.fold(0, (max, s) => s.id > max ? s.id : max) + 1;

  bool get canEdit => status == LoadStatus.loaded && !saving;

  SurgeSessionsState copyWith({
    LoadStatus? status,
    List<SurgeSession>? sessions,
    String? errorMessage,
    bool? saving,
  }) {
    return SurgeSessionsState(
      status: status ?? this.status,
      sessions: sessions ?? this.sessions,
      errorMessage: errorMessage ?? this.errorMessage,
      saving: saving ?? this.saving,
    );
  }
}
