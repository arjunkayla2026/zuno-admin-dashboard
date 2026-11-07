import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/data/mock/surge_session_mock_data.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/data/models/surge_session.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/state/surge_sessions_state.dart';

class SurgeSessionsCubit extends Cubit<SurgeSessionsState> {
  SurgeSessionsCubit()
    : super(const SurgeSessionsState(sessions: SurgeSessionMockData.sessions));

  void addSession(SurgeSession session) => emit(
    state.copyWith(
      sessions: [
        ...state.sessions,
        session.copyWith(id: state.nextId),
      ],
    ),
  );

  void updateSession(SurgeSession session) => emit(
    state.copyWith(
      sessions: [
        for (final current in state.sessions)
          current.id == session.id ? session : current,
      ],
    ),
  );

  void setEnabled(SurgeSession session, bool enabled) =>
      updateSession(session.copyWith(enabled: enabled));

  void removeSession(SurgeSession session) => emit(
    state.copyWith(
      sessions: [
        for (final current in state.sessions)
          if (current.id != session.id) current,
      ],
    ),
  );
}
