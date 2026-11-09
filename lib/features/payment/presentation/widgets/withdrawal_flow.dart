import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_export_file_tile.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_success_dialog.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_cubit.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_state.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_details_sheet.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_review_summary.dart';

const double _reviewDialogWidth = 420;

Future<void> openWithdrawalDetails(
  BuildContext context,
  Withdrawal withdrawal,
) {
  return showAppSideSheet<void>(
    context: context,
    builder: (sheetContext) => WithdrawalDetailsSheet(
      withdrawal: withdrawal,
      onWithdraw: () => _reviewWithdrawal(context, sheetContext, withdrawal),
    ),
  );
}

Future<void> _reviewWithdrawal(
  BuildContext pageContext,
  BuildContext sheetContext,
  Withdrawal withdrawal,
) async {
  final cubit = pageContext.read<PaymentCubit>();
  final tdsPercent = cubit.state.tdsPercent;
  final emphasis = AppTextStyles.tableCell.copyWith(
    fontWeight: FontWeight.w700,
  );

  final confirmed = await showAppConfirmDialog(
    context: sheetContext,
    iconAsset: AppImages.paymentIcon,
    title: AppStrings.reviewWithdrawalTitle,
    message: TextSpan(
      children: [
        const TextSpan(text: AppStrings.reviewWithdrawalPrefix),
        TextSpan(text: withdrawal.hostName, style: emphasis),
        TextSpan(text: AppStrings.reviewWithdrawalSuffix(withdrawal.hostId)),
      ],
    ),
    details: WithdrawalReviewSummary(
      withdrawal: withdrawal,
      tdsPercent: tdsPercent,
    ),
    confirmLabel: AppStrings.confirmWithdrawal,
    brand: true,
    width: _reviewDialogWidth,
  );
  if (!confirmed || !sheetContext.mounted) return;

  cubit.markPaid(withdrawal);
  Navigator.of(sheetContext).pop();
  if (!pageContext.mounted) return;

  await showAppSuccessDialog(
    context: pageContext,
    title: AppStrings.withdrawalCompleted,
    message: AppStrings.withdrawalCompletedMessage(
      NumberFormatter.rupeesPaise(withdrawal.receivablePaise(tdsPercent)),
      withdrawal.hostName,
    ),
    actionLabel: AppStrings.done,
  );
}

Future<void> exportWithdrawals(BuildContext context) {
  final state = context.read<PaymentCubit>().state;
  final rowCount = state.visibleWithdrawals.length;
  final scope = switch (state.tab) {
    PaymentTab.withdrawalList => AppStrings.exportScopeAll,
    PaymentTab.pending => AppStrings.exportScopePending,
    PaymentTab.success => AppStrings.exportScopeSuccess,
  };

  return showAppSuccessDialog(
    context: context,
    title: AppStrings.exportComplete,
    message: AppStrings.withdrawalsExported(rowCount),
    details: AppExportFileTile(
      fileName: AppStrings.withdrawalSheetFileName(
        scope,
        DateFormatter.short(state.today).replaceAll(' ', '-'),
      ),
      description: AppStrings.withdrawalSheetRows(rowCount),
    ),
    actionLabel: AppStrings.done,
  );
}
