import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/settings/data/repositories/settings_repository.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/data/models/surge_session.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/state/surge_sessions_state.dart';

class SurgeSessionsCubit extends Cubit<SurgeSessionsState> {
  SurgeSessionsCubit(this._repository) : super(const SurgeSessionsState());

  final SettingsRepository _repository;

  Future<void> load() async {
    emit(SurgeSessionsState(sessions: state.sessions));
    final result = await _repository.fetchSurgeSessions();
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => SurgeSessionsState(
          status: LoadStatus.failure,
          sessions: state.sessions,
          errorMessage: failure.message,
        ),
        (sessions) =>
            SurgeSessionsState(status: LoadStatus.loaded, sessions: sessions),
      ),
    );
  }

  Future<void> refresh() async {
    if (state.saving) return;
    await load();
  }

  Future<String?> addSession(SurgeSession session) async =>
      _invalidReason(session) ??
      await _save([...state.sessions, session.copyWith(id: state.nextId)]);

  Future<String?> updateSession(SurgeSession session) async =>
      _invalidReason(session) ?? await _replace(session);

  Future<String?> setEnabled(SurgeSession session, bool enabled) =>
      _replace(session.copyWith(enabled: enabled));

  Future<String?> removeSession(SurgeSession session) => _save([
    for (final current in state.sessions)
      if (current.id != session.id) current,
  ]);

  String? _invalidReason(SurgeSession session) {
    final start = session.startMinutes;
    final end = session.endMinutes;
    if (start == null || end == null) return AppStrings.selectTime;
    if (start == end) return AppStrings.endTimeMustDiffer;
    if (!SurgeSession.isValidPercent(session.percent)) {
      return AppStrings.surgeChargeInvalid;
    }
    return SurgeSession.firstOverlap(
      state.sessions,
      startMinutes: start,
      endMinutes: end,
      skipId: session.id,
    )?.overlapMessage;
  }

  Future<String?> _replace(SurgeSession session) => _save([
    for (final current in state.sessions)
      current.id == session.id ? session : current,
  ]);

  Future<String?> _save(List<SurgeSession> sessions) async {
    if (!state.canEdit) return AppStrings.surgeSessionsBusy;
    emit(state.copyWith(saving: true));
    final result = await _repository.saveSurgeSessions(sessions);
    if (isClosed) return null;
    return result.fold(
      (failure) {
        emit(state.copyWith(saving: false));
        return failure.message;
      },
      (_) {
        emit(state.copyWith(sessions: sessions, saving: false));
        return null;
      },
    );
  }
}
