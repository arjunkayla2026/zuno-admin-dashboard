import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_success_dialog.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/mock_withdrawals_cubit.dart';

Future<void> generateMockWithdrawals(BuildContext context) async {
  final cubit = context.read<MockWithdrawalsCubit>();
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showAppConfirmDialog(
    context: context,
    iconAsset: AppImages.paymentIcon,
    title: AppStrings.mockGenerateTitle,
    message: const TextSpan(text: AppStrings.mockGenerateMessage),
    confirmLabel: AppStrings.generateMockWithdrawals,
    brand: true,
  );
  if (!confirmed || !context.mounted) return;
  final result = await cubit.generate();
  if (result == null || !context.mounted) return;
  switch (result) {
    case Left(value: final failure):
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    case Right(value: final created):
      await showAppSuccessDialog(
        context: context,
        title: AppStrings.mockGeneratedTitle,
        message: AppStrings.mockGeneratedMessage(
          created.payouts,
          created.hosts,
        ),
        actionLabel: AppStrings.done,
      );
  }
}

Future<void> clearMockWithdrawals(BuildContext context) async {
  final cubit = context.read<MockWithdrawalsCubit>();
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showAppConfirmDialog(
    context: context,
    iconAsset: AppImages.paymentIcon,
    title: AppStrings.mockClearTitle,
    message: const TextSpan(text: AppStrings.mockClearMessage),
    confirmLabel: AppStrings.clearMockData,
  );
  if (!confirmed || !context.mounted) return;
  final result = await cubit.clear();
  if (result == null || !context.mounted) return;
  switch (result) {
    case Left(value: final failure):
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    case Right(value: final deleted):
      await showAppSuccessDialog(
        context: context,
        title: AppStrings.mockClearDoneTitle,
        message: AppStrings.mockClearDoneMessage(deleted),
        actionLabel: AppStrings.done,
      );
  }
}
