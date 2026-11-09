import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/notification_send_summary.dart';

Future<bool> confirmSendNotification({
  required BuildContext context,
  required int recipients,
  required String audience,
  required String languages,
  required String title,
}) {
  return showAppConfirmDialog(
    context: context,
    iconAsset: AppImages.sendNotificationIcon,
    title: AppStrings.sendNotificationTitle,
    message: TextSpan(
      children: [
        const TextSpan(text: AppStrings.sendNotificationPrefix),
        TextSpan(
          text: NumberFormatter.grouped(recipients),
          style: AppTextStyles.tableCell.copyWith(fontWeight: FontWeight.w700),
        ),
        const TextSpan(text: AppStrings.sendNotificationSuffix),
      ],
    ),
    details: NotificationSendSummary(
      audience: audience,
      languages: languages,
      title: title,
    ),
    confirmLabel: AppStrings.sendNow,
    brand: true,
  );
}
