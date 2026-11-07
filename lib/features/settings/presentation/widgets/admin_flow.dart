import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/admin_account.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/admin_sheet.dart';

Future<void> openAdminSheet(BuildContext context, {AdminAccount? admin}) async {
  final cubit = context.read<SettingsCubit>();
  final saved = await showAppSideSheet<AdminAccount>(
    context: context,
    builder: (_) => AdminSheet(admin: admin),
  );
  if (saved != null) cubit.saveAdmin(saved, replacing: admin);
}
