import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/data/models/surge_session.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/state/surge_sessions_cubit.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/widgets/surge_session_sheet.dart';

Future<void> createSurgeSession(BuildContext context) async {
  final cubit = context.read<SurgeSessionsCubit>();
  final session = await showAppSideSheet<SurgeSession>(
    context: context,
    builder: (_) => const SurgeSessionSheet(),
  );
  if (session != null) cubit.addSession(session);
}

Future<void> editSurgeSession(
  BuildContext context,
  SurgeSession session,
) async {
  final cubit = context.read<SurgeSessionsCubit>();
  final edited = await showAppSideSheet<SurgeSession>(
    context: context,
    builder: (_) => SurgeSessionSheet(session: session),
  );
  if (edited != null) cubit.updateSession(edited);
}

Future<void> removeSurgeSession(
  BuildContext context,
  SurgeSession session,
) async {
  final cubit = context.read<SurgeSessionsCubit>();
  final confirmed = await showAppConfirmDialog(
    context: context,
    icon: Icons.delete_outline_rounded,
    title: AppStrings.removeSurgeSessionTitle,
    message: TextSpan(
      text: AppStrings.removeSurgeSessionMessage(
        DateFormatter.minutesOfDay(session.startMinutes),
        DateFormatter.minutesOfDay(session.endMinutes),
        session.percent,
      ),
    ),
    confirmLabel: AppStrings.removeSession,
  );
  if (confirmed) cubit.removeSession(session);
}
