import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_success_dialog.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';

Future<void> saveMinimumPayout(BuildContext context, double amount) async {
  final messenger = ScaffoldMessenger.of(context);
  final error = await context.read<SettingsCubit>().saveMinimumPayout(amount);
  messenger.showSnackBar(
    SnackBar(content: Text(error ?? AppStrings.minimumPayoutSaved)),
  );
}

Future<bool> changeAllowedVersion(
  BuildContext context,
  String version, {
  required bool add,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final error = await context.read<SettingsCubit>().changeAllowedVersion(
    version,
    add: add,
  );
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        error ??
            (add
                ? AppStrings.allowedVersionAdded
                : AppStrings.allowedVersionRemoved),
      ),
    ),
  );
  return error == null;
}

Future<void> toggleMaintenance(BuildContext context, bool enable) async {
  final cubit = context.read<SettingsCubit>();
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showAppConfirmDialog(
    context: context,
    iconAsset: AppImages.maintenanceModeIcon,
    title: enable
        ? AppStrings.turnOnMaintenanceTitle
        : AppStrings.turnOffMaintenanceTitle,
    message: TextSpan(
      text: enable
          ? AppStrings.turnOnMaintenanceMessage
          : AppStrings.turnOffMaintenanceMessage,
    ),
    confirmLabel: enable ? AppStrings.turnOn : AppStrings.turnOff,
    positive: !enable,
  );
  if (!confirmed) return;

  final error = await cubit.setMaintenance(enable);
  if (error != null) {
    messenger.showSnackBar(SnackBar(content: Text(error)));
    return;
  }
  if (!enable || !context.mounted) return;

  await showAppSuccessDialog(
    context: context,
    title: AppStrings.maintenanceModeIsOn,
    message: AppStrings.maintenanceOnMessage,
    actionLabel: AppStrings.done,
  );
}
