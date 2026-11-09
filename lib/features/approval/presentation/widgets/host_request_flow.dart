import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_success_dialog.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/host_request.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_cubit.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/host_request_sheet.dart';

Future<void> openHostRequest(BuildContext context, HostRequest request) async {
  final cubit = context.read<ApprovalCubit>();
  final decision = await showAppSideSheet<HostRequestStatus>(
    context: context,
    builder: (_) => HostRequestSheet(
      request: request,
      onChanged: cubit.updateRequest,
      onReview: cubit.reviewDocument,
      onDecide: cubit.decideRequest,
    ),
  );
  if (decision != HostRequestStatus.approved || !context.mounted) return;

  await showAppSuccessDialog(
    context: context,
    title: AppStrings.hostRequestApproved,
    actionLabel: AppStrings.done,
    messageSpan: TextSpan(
      children: [
        TextSpan(text: AppStrings.statusNowLead(request.realName)),
        TextSpan(
          text: AppStrings.approved,
          style: TextStyle(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const TextSpan(text: AppStrings.statusNowSuffix),
      ],
    ),
  );
}
