import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/data/models/surge_session.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/state/surge_sessions_cubit.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/widgets/surge_session_sheet.dart';

Set<String> _namesExcept(List<SurgeSession> sessions, [SurgeSession? skip]) => {
  for (final session in sessions)
    if (session.id != skip?.id) SurgeSessionSheet.nameKey(session.name),
};

String _time(int? minutes) => minutes == null
    ? AppStrings.emptyValue
    : DateFormatter.minutesOfDay(minutes);

void _showError(ScaffoldMessengerState messenger, String? error) {
  if (error != null) messenger.showSnackBar(SnackBar(content: Text(error)));
}

Future<void> createSurgeSession(BuildContext context) async {
  final cubit = context.read<SurgeSessionsCubit>();
  await showAppSideSheet<void>(
    context: context,
    builder: (_) => SurgeSessionSheet(
      takenNames: _namesExcept(cubit.state.sessions),
      onSave: cubit.addSession,
    ),
  );
}

Future<void> editSurgeSession(
  BuildContext context,
  SurgeSession session,
) async {
  final cubit = context.read<SurgeSessionsCubit>();
  await showAppSideSheet<void>(
    context: context,
    builder: (_) => SurgeSessionSheet(
      session: session,
      takenNames: _namesExcept(cubit.state.sessions, session),
      onSave: cubit.updateSession,
    ),
  );
}

Future<void> setSurgeSessionEnabled(
  BuildContext context,
  SurgeSession session,
  bool enabled,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final error = await context.read<SurgeSessionsCubit>().setEnabled(
    session,
    enabled,
  );
  _showError(messenger, error);
}

Future<void> removeSurgeSession(
  BuildContext context,
  SurgeSession session,
) async {
  final cubit = context.read<SurgeSessionsCubit>();
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showAppConfirmDialog(
    context: context,
    icon: Icons.delete_outline_rounded,
    title: AppStrings.removeSurgeSessionTitle,
    message: TextSpan(
      text: AppStrings.removeSurgeSessionMessage(
        session.name,
        _time(session.startMinutes),
        _time(session.endMinutes),
        session.percent,
      ),
    ),
    confirmLabel: AppStrings.removeSession,
  );
  if (confirmed) _showError(messenger, await cubit.removeSession(session));
}
