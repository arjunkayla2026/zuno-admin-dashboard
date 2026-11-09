import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_action_menu.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_success_dialog.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_actions_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/widgets/edit_user_sheet.dart';

Future<void> runUserAction({
  required BuildContext context,
  required AppMenuAction action,
  required AdminUser user,
  required ValueChanged<AdminUser> onUserChanged,
}) {
  return switch (action) {
    AppMenuAction.edit => _editUser(context, user, onUserChanged),
    AppMenuAction.block => _confirmBlock(context, user, onUserChanged),
    AppMenuAction.unblock => _confirmUnblock(context, user, onUserChanged),
    AppMenuAction.delete => _confirmDelete(context, user, onUserChanged),
  };
}

Future<void> _persist(
  BuildContext context,
  Future<String?> Function(UserActionsCubit actions) write,
  VoidCallback onSaved,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final error = await write(context.read<UserActionsCubit>());
  if (error != null) {
    messenger.showSnackBar(SnackBar(content: Text(error)));
  } else if (context.mounted) {
    onSaved();
  }
}

Future<void> _confirmBlock(
  BuildContext context,
  AdminUser user,
  ValueChanged<AdminUser> onUserChanged,
) async {
  final confirmed = await showAppConfirmDialog(
    context: context,
    icon: Icons.block_flipped,
    title: AppStrings.blockUserTitle(user.name),
    message: const TextSpan(text: AppStrings.blockUserMessage),
    confirmLabel: AppStrings.blockUserAction,
  );
  if (!confirmed || !context.mounted) return;

  await _persist(
    context,
    (actions) => actions.setBlocked(user, blocked: true),
    () => onUserChanged(user.copyWith(status: UserStatus.blocked)),
  );
}

Future<void> _confirmUnblock(
  BuildContext context,
  AdminUser user,
  ValueChanged<AdminUser> onUserChanged,
) async {
  final confirmed = await showAppConfirmDialog(
    context: context,
    icon: Icons.lock_open_rounded,
    title: AppStrings.unblockUserTitle(user.name),
    message: const TextSpan(text: AppStrings.unblockUserMessage),
    confirmLabel: AppStrings.unblockUserAction,
    positive: true,
  );
  if (!confirmed || !context.mounted) return;

  await _persist(
    context,
    (actions) => actions.setBlocked(user, blocked: false),
    () => onUserChanged(user.copyWith(status: UserStatus.active)),
  );
}

Future<void> _confirmDelete(
  BuildContext context,
  AdminUser user,
  ValueChanged<AdminUser> onUserChanged,
) async {
  final confirmed = await showAppConfirmDialog(
    context: context,
    icon: Icons.delete_outline_rounded,
    title: AppStrings.deleteAccountTitle(user.name),
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
    (actions) => actions.delete(user),
    () => onUserChanged(user.copyWith(status: UserStatus.deletedByAdmin)),
  );
}

Future<void> _editUser(
  BuildContext context,
  AdminUser user,
  ValueChanged<AdminUser> onUserChanged,
) async {
  final actions = context.read<UserActionsCubit>();
  final edited = await showAppSideSheet<EditedUser>(
    context: context,
    builder: (_) => EditUserSheet(
      user: user,
      onSave: (edited) =>
          actions.saveDetails(user, name: edited.name, phone: edited.phone),
    ),
  );
  if (edited == null || !context.mounted) return;

  onUserChanged(user.withEditedDetails(name: edited.name, phone: edited.phone));

  await showAppSuccessDialog(
    context: context,
    title: AppStrings.userDetailsUpdated,
    message: AppStrings.userDetailsSaved(edited.name),
    actionLabel: AppStrings.done,
  );
}
