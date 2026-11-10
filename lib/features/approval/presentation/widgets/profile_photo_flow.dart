import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/profile_photo_request.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_cubit.dart';

Future<void> decideProfilePhoto(
  BuildContext context,
  ProfilePhotoRequest photo, {
  required bool accept,
}) async {
  final cubit = context.read<ApprovalCubit>();
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showAppConfirmDialog(
    context: context,
    icon: accept ? Icons.check_circle_outline_rounded : Icons.close_rounded,
    title: accept ? AppStrings.acceptPhotoTitle : AppStrings.rejectPhotoTitle,
    message: TextSpan(
      text: accept
          ? AppStrings.acceptPhotoMessage(photo.hostName)
          : AppStrings.rejectPhotoMessage(photo.hostName),
    ),
    confirmLabel: accept ? AppStrings.accept : AppStrings.reject,
    positive: accept,
  );
  if (!confirmed) return;
  final error = await cubit.decideProfilePhoto(
    photo,
    accept ? ProfilePhotoStatus.accepted : ProfilePhotoStatus.rejected,
  );
  if (error != null) messenger.showSnackBar(SnackBar(content: Text(error)));
}
