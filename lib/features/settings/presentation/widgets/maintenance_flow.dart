import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_success_dialog.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';

Future<void> toggleMaintenance(BuildContext context, bool enable) async {
  final cubit = context.read<SettingsCubit>();
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

  cubit.setMaintenance(enable);
  if (!enable || !context.mounted) return;

  await showAppSuccessDialog(
    context: context,
    title: AppStrings.maintenanceModeIsOn,
    message: AppStrings.maintenanceOnMessage,
    actionLabel: AppStrings.done,
  );
}
