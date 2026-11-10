import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/payout_request.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_cubit.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/payout_request_sheet.dart';

Future<void> openPayoutRequest(BuildContext context, PayoutRequest payout) {
  final cubit = context.read<ApprovalCubit>();
  return showAppSideSheet<void>(
    context: context,
    builder: (_) =>
        PayoutRequestSheet(payout: payout, onDecide: cubit.decidePayout),
  );
}
