import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_action_menu.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_success_dialog.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
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
    AppMenuAction.delete => _confirmDelete(context, host, onHostChanged),
  };
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
  if (confirmed) onHostChanged(host.copyWith(status: HostStatus.blocked));
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
  if (confirmed) {
    onHostChanged(host.copyWith(status: HostStatus.deletedByAdmin));
  }
}

Future<void> _editHost(
  BuildContext context,
  AdminHost host,
  ValueChanged<AdminHost> onHostChanged,
) async {
  final edited = await showAppSideSheet<AdminHost>(
    context: context,
    builder: (_) => EditHostSheet(host: host),
  );
  if (edited == null) return;

  onHostChanged(edited);
  if (!context.mounted) return;

  await showAppSuccessDialog(
    context: context,
    title: AppStrings.hostDetailsUpdated,
    message: AppStrings.userDetailsSaved(edited.name),
    actionLabel: AppStrings.done,
  );
}
