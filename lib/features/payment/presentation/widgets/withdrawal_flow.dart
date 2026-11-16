import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_export_file_tile.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_success_dialog.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_batch_result.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_cubit.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_state.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/payout_batch_failures.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_details_sheet.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_review_summary.dart';

const double _reviewDialogWidth = 420;

double _totalOf(Iterable<Withdrawal> withdrawals) =>
    withdrawals.fold(0, (total, item) => total + item.totalAmount);

double _tdsOf(Iterable<Withdrawal> withdrawals) => withdrawals.fold(
  0,
  (total, item) => total + item.tdsAmount(PaymentState.tdsPercent),
);

Future<void> openWithdrawalDetails(
  BuildContext context,
  Withdrawal withdrawal,
) {
  return showAppSideSheet<void>(
    context: context,
    builder: (sheetContext) => WithdrawalDetailsSheet(
      withdrawal: withdrawal,
      onMoveToPending: withdrawal.isOpen && withdrawal.hasBankAccount
          ? () => _moveFromSheet(context, sheetContext, withdrawal)
          : null,
      onWithdraw: withdrawal.isPending
          ? () => _reviewWithdrawal(context, sheetContext, withdrawal)
          : null,
    ),
  );
}

Future<void> selectAllWithdrawals(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final failure = await context.read<PaymentCubit>().selectAllMatching();
  if (failure != null) {
    messenger.showSnackBar(SnackBar(content: Text(failure.message)));
  }
}

Future<void> moveSelectedToPending(BuildContext context) async {
  final cubit = context.read<PaymentCubit>();
  final selection = cubit.state.selected.values.toList();
  if (selection.isEmpty) return;
  if (!await _confirmMove(context, selection) || !context.mounted) return;
  final result = await cubit.moveSelectedToPending();
  if (!context.mounted) return;
  await _showMoveResult(context, result);
}

Future<void> markSelectedPaid(BuildContext context) async {
  final cubit = context.read<PaymentCubit>();
  final selection = cubit.state.selected.values.toList();
  if (selection.isEmpty) return;
  final confirmed = await showAppConfirmDialog(
    context: context,
    iconAsset: AppImages.paymentIcon,
    title: AppStrings.markPaidTitle(selection.length),
    message: TextSpan(
      text: AppStrings.markPaidMessage(
        selection.length,
        NumberFormatter.rupeesAmount(_totalOf(selection)),
        NumberFormatter.rupeesAmount(_tdsOf(selection)),
      ),
    ),
    confirmLabel: AppStrings.markAsSuccess,
    positive: true,
  );
  if (!confirmed || !context.mounted) return;
  final result = await cubit.markSelectedPaid();
  if (!context.mounted) return;
  await _showBatchResult(
    context,
    result,
    title: AppStrings.payoutsCompletedTitle,
    message: (batch) => AppStrings.payoutsCompletedMessage(
      batch.succeeded.length,
      NumberFormatter.rupeesAmount(batch.succeededTotal),
    ),
  );
}

Future<bool> _confirmMove(BuildContext context, List<Withdrawal> selection) =>
    showAppConfirmDialog(
      context: context,
      iconAsset: AppImages.paymentIcon,
      title: AppStrings.moveToPendingTitle(selection.length),
      message: TextSpan(
        text: AppStrings.moveToPendingMessage(
          selection.length,
          NumberFormatter.rupeesAmount(_totalOf(selection)),
        ),
      ),
      confirmLabel: AppStrings.moveToPending,
      brand: true,
    );

Future<void> _showMoveResult(
  BuildContext context,
  Either<Failure, PayoutBatchResult> result,
) => _showBatchResult(
  context,
  result,
  title: AppStrings.movedToPendingTitle,
  message: (batch) => AppStrings.movedToPendingMessage(
    batch.succeeded.length,
    NumberFormatter.rupeesAmount(batch.succeededTotal),
  ),
);

Future<void> _showBatchResult(
  BuildContext context,
  Either<Failure, PayoutBatchResult> result, {
  required String title,
  required String Function(PayoutBatchResult batch) message,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  switch (result) {
    case Left(value: final failure):
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    case Right(value: final batch) when !batch.hasSuccess:
      final reason = batch.failed.isEmpty
          ? AppStrings.payoutFailed
          : batch.failed.first.message;
      messenger.showSnackBar(
        SnackBar(content: Text(AppStrings.payoutBatchNoneDone(reason))),
      );
    case Right(value: final batch):
      await showAppSuccessDialog(
        context: context,
        title: title,
        message: message(batch),
        details: batch.failed.isEmpty
            ? null
            : PayoutBatchFailures(failures: batch.failed),
        actionLabel: AppStrings.done,
      );
  }
}

Future<void> _moveFromSheet(
  BuildContext pageContext,
  BuildContext sheetContext,
  Withdrawal withdrawal,
) async {
  final cubit = pageContext.read<PaymentCubit>();
  if (!await _confirmMove(sheetContext, [withdrawal]) ||
      !sheetContext.mounted) {
    return;
  }
  final result = await cubit.moveToPending([withdrawal]);
  final moved = result.match((_) => false, (batch) => batch.hasSuccess);
  if (moved && sheetContext.mounted) Navigator.of(sheetContext).pop();
  if (!pageContext.mounted) return;
  await _showMoveResult(pageContext, result);
}

Future<void> _reviewWithdrawal(
  BuildContext pageContext,
  BuildContext sheetContext,
  Withdrawal withdrawal,
) async {
  final cubit = pageContext.read<PaymentCubit>();
  final messenger = ScaffoldMessenger.of(pageContext);
  if (!withdrawal.hasBankAccount) {
    messenger.showSnackBar(
      const SnackBar(content: Text(AppStrings.payoutNoBankAccount)),
    );
    return;
  }
  const tdsPercent = PaymentState.tdsPercent;
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

  final result = await cubit.markPaid([withdrawal]);
  final paid = switch (result) {
    Left(value: final failure) => () {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
      return null;
    }(),
    Right(value: final batch) when !batch.hasSuccess => () {
      final reason = batch.failed.isEmpty
          ? AppStrings.payoutFailed
          : batch.failed.first.message;
      messenger.showSnackBar(SnackBar(content: Text(reason)));
      return null;
    }(),
    Right(value: final batch) => batch.succeeded.first,
  };
  if (paid == null) return;
  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
  if (!pageContext.mounted) return;

  await showAppSuccessDialog(
    context: pageContext,
    title: AppStrings.withdrawalCompleted,
    message: AppStrings.withdrawalCompletedMessage(
      NumberFormatter.rupeesAmount(paid.receivableAmount(tdsPercent)),
      withdrawal.hostName,
    ),
    actionLabel: AppStrings.done,
  );
}

String _exportScope(PaymentTab tab) => switch (tab) {
  PaymentTab.withdrawalList => AppStrings.exportScopeAll,
  PaymentTab.pending => AppStrings.exportScopePending,
  PaymentTab.success => AppStrings.exportScopeSuccess,
};

Future<void> exportBeneficiaries(BuildContext context) {
  final state = context.read<PaymentCubit>().state;
  final rowCount = state.totalCount ?? state.withdrawals.length;

  return showAppSuccessDialog(
    context: context,
    title: AppStrings.exportComplete,
    message: AppStrings.beneficiariesExported(rowCount),
    details: AppExportFileTile(
      fileName: AppStrings.beneficiarySheetFileName(
        _exportScope(state.tab),
        DateFormatter.short(DateTime.now()).replaceAll(' ', '-'),
      ),
      description: AppStrings.beneficiarySheetRows(rowCount),
    ),
    actionLabel: AppStrings.done,
  );
}

Future<void> exportWithdrawals(BuildContext context) {
  final state = context.read<PaymentCubit>().state;
  final rowCount = state.totalCount ?? state.withdrawals.length;

  return showAppSuccessDialog(
    context: context,
    title: AppStrings.exportComplete,
    message: AppStrings.withdrawalsExported(rowCount),
    details: AppExportFileTile(
      fileName: AppStrings.withdrawalSheetFileName(
        _exportScope(state.tab),
        DateFormatter.short(DateTime.now()).replaceAll(' ', '-'),
      ),
      description: AppStrings.withdrawalSheetRows(rowCount),
    ),
    actionLabel: AppStrings.done,
  );
}
