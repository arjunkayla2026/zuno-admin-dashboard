import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/file_download.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_export_file_tile.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_success_dialog.dart';
import 'package:zuno_admin_dashboard/features/payment/data/exporters/payout_sheet_exporter.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_batch_result.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_failure_reason.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_sheet_row.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_cubit.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_state.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/payout_batch_failures.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/payout_failure_dialog.dart';
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
      onMarkFailed: withdrawal.isPending
          ? () => _failFromSheet(context, sheetContext, withdrawal)
          : null,
      onRetry: withdrawal.isFailed
          ? () => _retryFromSheet(context, sheetContext, withdrawal)
          : null,
    ),
  );
}

Future<void> retrySelected(BuildContext context) async {
  final cubit = context.read<PaymentCubit>();
  final selection = cubit.state.selected.values.toList();
  if (selection.isEmpty) return;
  if (!await _confirmRetry(context, selection) || !context.mounted) return;
  final result = await cubit.retrySelected();
  if (!context.mounted) return;
  await _showRetryResult(context, result);
}

Future<PayoutFailureInput?> _askFailure(
  BuildContext context,
  List<Withdrawal> selection,
) => showPayoutFailureDialog(
  context: context,
  title: AppStrings.markFailedTitle(selection.length),
  message: AppStrings.markFailedMessage(
    selection.length,
    NumberFormatter.rupeesAmount(_totalOf(selection)),
  ),
);

Future<bool> _confirmRetry(BuildContext context, List<Withdrawal> selection) =>
    showAppConfirmDialog(
      context: context,
      iconAsset: AppImages.paymentIcon,
      title: AppStrings.retryPayoutTitle(selection.length),
      message: TextSpan(
        text: AppStrings.retryPayoutMessage(
          selection.length,
          NumberFormatter.rupeesAmount(_totalOf(selection)),
        ),
      ),
      confirmLabel: AppStrings.retryPayout,
      brand: true,
    );

Future<void> _showFailResult(
  BuildContext context,
  Either<Failure, PayoutBatchResult> result,
) => _showBatchResult(
  context,
  result,
  title: AppStrings.markedFailedTitle,
  message: (batch) => AppStrings.markedFailedMessage(
    batch.succeeded.length,
    NumberFormatter.rupeesAmount(batch.succeededTotal),
  ),
);

Future<void> _showRetryResult(
  BuildContext context,
  Either<Failure, PayoutBatchResult> result,
) => _showBatchResult(
  context,
  result,
  title: AppStrings.movedBackToPendingTitle,
  message: (batch) => AppStrings.movedBackToPendingMessage(
    batch.succeeded.length,
    NumberFormatter.rupeesAmount(batch.succeededTotal),
  ),
);

Future<void> _failFromSheet(
  BuildContext pageContext,
  BuildContext sheetContext,
  Withdrawal withdrawal,
) async {
  final cubit = pageContext.read<PaymentCubit>();
  final failure = await _askFailure(sheetContext, [withdrawal]);
  if (failure == null || !sheetContext.mounted) return;
  final result = await cubit.markFailed([withdrawal], failure);
  final failed = result.match((_) => false, (batch) => batch.hasSuccess);
  if (failed && sheetContext.mounted) Navigator.of(sheetContext).pop();
  if (!pageContext.mounted) return;
  await _showFailResult(pageContext, result);
}

Future<void> _retryFromSheet(
  BuildContext pageContext,
  BuildContext sheetContext,
  Withdrawal withdrawal,
) async {
  final cubit = pageContext.read<PaymentCubit>();
  if (!withdrawal.hasBankAccount) {
    ScaffoldMessenger.of(pageContext).showSnackBar(
      const SnackBar(content: Text(AppStrings.payoutNoBankAccount)),
    );
    return;
  }
  if (!await _confirmRetry(sheetContext, [withdrawal]) ||
      !sheetContext.mounted) {
    return;
  }
  final result = await cubit.retryFailed([withdrawal]);
  final retried = result.match((_) => false, (batch) => batch.hasSuccess);
  if (retried && sheetContext.mounted) Navigator.of(sheetContext).pop();
  if (!pageContext.mounted) return;
  await _showRetryResult(pageContext, result);
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

Future<void> markSelectedPaid(BuildContext context) => markWithdrawalsPaid(
  context,
  context.read<PaymentCubit>().state.selectedPending,
);

/// Rejects a pending payout through the existing Mark as Failed action, with
/// the reason Rejected by the bank. Nothing is added to the host's withdrawn
/// total.
Future<void> rejectWithdrawal(
  BuildContext context,
  Withdrawal withdrawal,
) async {
  final cubit = context.read<PaymentCubit>();
  final confirmed = await showAppConfirmDialog(
    context: context,
    iconAsset: AppImages.paymentIcon,
    title: AppStrings.rejectWithdrawalTitle,
    message: TextSpan(
      text: AppStrings.rejectWithdrawalMessage(
        NumberFormatter.rupeesAmount(withdrawal.totalAmount),
        withdrawal.hostName,
      ),
    ),
    confirmLabel: AppStrings.reject,
  );
  if (!confirmed || !context.mounted) return;
  final result = await cubit.markFailed(
    [withdrawal],
    const PayoutFailureInput(
      reason: PayoutFailureReason.bankRejected,
      note: AppStrings.rejectedInTesting,
    ),
  );
  if (!context.mounted) return;
  await _showFailResult(context, result);
}

Future<void> markWithdrawalsPaid(
  BuildContext context,
  List<Withdrawal> selection,
) async {
  final cubit = context.read<PaymentCubit>();
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
  final result = await cubit.markPaid(selection);
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

Future<void> exportBeneficiaries(BuildContext context) => _exportSheet(
  context,
  build: (rows, _) => PayoutSheetExporter.beneficiaries(rows),
  fileName: AppStrings.beneficiarySheetFileName,
  message: (count, _) => AppStrings.beneficiariesExported(count),
  description: AppStrings.beneficiarySheetRows,
  registerBeneficiaries: true,
);

Future<void> exportWithdrawals(BuildContext context) => _exportSheet(
  context,
  build: PayoutSheetExporter.withdrawals,
  fileName: AppStrings.withdrawalSheetFileName,
  message: (count, skipped) => skipped == 0
      ? AppStrings.withdrawalsExported(count)
      : AppStrings.withdrawalsExportedSkipping(count, skipped),
  description: AppStrings.withdrawalSheetRows,
  requireBeneficiary: true,
);

Future<void> _exportSheet(
  BuildContext context, {
  required Uint8List Function(List<PayoutSheetRow> rows, DateTime today) build,
  required String Function(String date) fileName,
  required String Function(int count, int skipped) message,
  required String Function(int count) description,
  bool registerBeneficiaries = false,
  bool requireBeneficiary = false,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final cubit = context.read<PaymentCubit>();
  final result = await cubit.loadSheetRows(
    registerBeneficiaries: registerBeneficiaries,
  );
  if (result == null || !context.mounted) return;

  switch (result) {
    case Left(value: final failure):
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    case Right(value: final load) when load.candidates == 0:
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.nothingToExport)),
      );
    case Right(value: final load) when load.rows.isEmpty:
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.noExportableWithdrawals)),
      );
    case Right(value: final load)
        when requireBeneficiary && !load.rows.any((row) => row.hasBeneficiary):
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.noRegisteredBeneficiaries)),
      );
    case Right(value: final load):
      final loaded = load.rows;
      final rows = requireBeneficiary
          ? loaded.where((row) => row.hasBeneficiary).toList()
          : loaded;
      final skipped = loaded.length - rows.length;
      final today = DateTime.now();
      final name = fileName(DateFormatter.short(today).replaceAll(' ', '-'));
      try {
        downloadFile(build(rows, today), name, PayoutSheetExporter.mimeType);
      } catch (_) {
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.exportFailed)),
        );
        return;
      }
      if (registerBeneficiaries) cubit.markBeneficiariesExported(load);
      await showAppSuccessDialog(
        context: context,
        title: AppStrings.exportComplete,
        message: message(rows.length, skipped),
        details: AppExportFileTile(
          fileName: name,
          description: description(rows.length),
        ),
        actionLabel: AppStrings.done,
      );
  }
}
