import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/data/admin_account.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/admin_session_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/admin_sheet.dart';

Future<void> openAdminSheet(BuildContext context, {AdminAccount? admin}) async {
  final cubit = context.read<SettingsCubit>();
  final session = context.read<AdminSessionCubit>();
  final saved = await showAppSideSheet<AdminAccount>(
    context: context,
    builder: (_) => AdminSheet(
      admin: admin,
      onSave: (updated, password) =>
          cubit.saveAdmin(updated, replacing: admin, password: password),
    ),
  );
  if (saved != null) session.refreshIfCurrent(saved);
}
