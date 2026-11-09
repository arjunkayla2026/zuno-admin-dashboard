import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_action_menu.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_success_dialog.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_actions_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/edit_host_sheet.dart';

Future<void> runHostAction({
  required BuildContext context,
  required AppMenuAction action,
  required AdminHost host,
  required ValueChanged<AdminHost> onHostChanged,
}) {
  return switch (action) {
    AppMenuAction.edit => _editHost(context, host, onHostChanged),
    AppMenuAction.block => _confirmBlock(context, host, onHostChanged),
    AppMenuAction.unblock => _confirmUnblock(context, host, onHostChanged),
    AppMenuAction.delete => _confirmDelete(context, host, onHostChanged),
  };
}

Future<void> _persist(
  BuildContext context,
  Future<String?> Function(HostActionsCubit actions) write,
  VoidCallback onSaved,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final error = await write(context.read<HostActionsCubit>());
  if (error != null) {
    messenger.showSnackBar(SnackBar(content: Text(error)));
  } else if (context.mounted) {
    onSaved();
  }
}

Future<void> _confirmBlock(
  BuildContext context,
  AdminHost host,
  ValueChanged<AdminHost> onHostChanged,
) async {
  final confirmed = await showAppConfirmDialog(
    context: context,
    icon: Icons.block_flipped,
    title: AppStrings.blockUserTitle(host.name),
    message: const TextSpan(text: AppStrings.blockHostMessage),
    confirmLabel: AppStrings.blockHostAction,
  );
  if (!confirmed || !context.mounted) return;

  await _persist(
    context,
    (actions) => actions.setBlocked(host, blocked: true),
    () => onHostChanged(host.copyWith(status: HostStatus.blocked)),
  );
}

Future<void> _confirmUnblock(
  BuildContext context,
  AdminHost host,
  ValueChanged<AdminHost> onHostChanged,
) async {
  final confirmed = await showAppConfirmDialog(
    context: context,
    icon: Icons.lock_open_rounded,
    title: AppStrings.unblockUserTitle(host.name),
    message: const TextSpan(text: AppStrings.unblockHostMessage),
    confirmLabel: AppStrings.unblockHostAction,
    positive: true,
  );
  if (!confirmed || !context.mounted) return;

  final status = host.isAccountActive ? HostStatus.active : HostStatus.inactive;
  await _persist(
    context,
    (actions) => actions.setBlocked(host, blocked: false),
    () => onHostChanged(host.copyWith(status: status)),
  );
}

Future<void> _confirmDelete(
  BuildContext context,
  AdminHost host,
  ValueChanged<AdminHost> onHostChanged,
) async {
  final confirmed = await showAppConfirmDialog(
    context: context,
    icon: Icons.delete_outline_rounded,
    title: AppStrings.deleteAccountTitle(host.name),
    message: TextSpan(
      children: [
        const TextSpan(text: AppStrings.deleteAccountMessageLead),
        TextSpan(
          text: AppStrings.deletedByAdmin,
          style: TextStyle(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const TextSpan(text: AppStrings.deleteAccountMessageTail),
      ],
    ),
    confirmLabel: AppStrings.deleteAccountAction,
  );
  if (!confirmed || !context.mounted) return;

  await _persist(
    context,
    (actions) => actions.delete(host),
    () => onHostChanged(host.copyWith(status: HostStatus.deletedByAdmin)),
  );
}

Future<void> _editHost(
  BuildContext context,
  AdminHost host,
  ValueChanged<AdminHost> onHostChanged,
) async {
  final actions = context.read<HostActionsCubit>();
  final edited = await showAppSideSheet<AdminHost>(
    context: context,
    builder: (_) => EditHostSheet(
      host: host,
      onSave: (edited) => actions.saveDetails(host, edited),
    ),
  );
  if (edited == null || !context.mounted) return;

  onHostChanged(edited);

  await showAppSuccessDialog(
    context: context,
    title: AppStrings.hostDetailsUpdated,
    message: AppStrings.userDetailsSaved(edited.name),
    actionLabel: AppStrings.done,
  );
}
