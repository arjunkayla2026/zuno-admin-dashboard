import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_action_menu.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_success_dialog.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';
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
    AppMenuAction.delete => _confirmDelete(context, user, onUserChanged),
  };
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
  if (confirmed) onUserChanged(user.copyWith(status: UserStatus.blocked));
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
  if (confirmed) {
    onUserChanged(user.copyWith(status: UserStatus.deletedByAdmin));
  }
}

Future<void> _editUser(
  BuildContext context,
  AdminUser user,
  ValueChanged<AdminUser> onUserChanged,
) async {
  final edited = await showAppSideSheet<EditedUser>(
    context: context,
    builder: (_) => EditUserSheet(user: user),
  );
  if (edited == null) return;

  onUserChanged(user.withEditedDetails(name: edited.name, phone: edited.phone));
  if (!context.mounted) return;

  await showAppSuccessDialog(
    context: context,
    title: AppStrings.userDetailsUpdated,
    message: AppStrings.userDetailsSaved(edited.name),
    actionLabel: AppStrings.done,
  );
}
