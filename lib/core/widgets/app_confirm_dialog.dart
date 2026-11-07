import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';

Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required IconData icon,
  required String title,
  required InlineSpan message,
  required String confirmLabel,
  bool positive = false,
}) async {
  final confirmed = await showAppDialog<bool>(
    context: context,
    builder: (_) => AppConfirmDialog(
      icon: icon,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      positive: positive,
    ),
  );
  return confirmed ?? false;
}

class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.positive = false,
  });

  static const double _iconTileSize = 44;
  static const double _iconSize = 24;
  static const double _iconGap = 14;
  static const double _titleInset = 2;
  static const double _messageGap = 18;
  static const double _actionsGap = 22;
  static const double _actionSpacing = 10;
  static const EdgeInsets _padding = EdgeInsets.all(AppUtils.spacingXl);

  final IconData icon;
  final String title;
  final InlineSpan message;
  final String confirmLabel;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tileColor = positive ? colors.activeBadge : colors.errorBadge;
    final iconColor = positive ? colors.activeText : colors.errorText;

    return AppDialogSurface(
      padding: _padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: _iconTileSize,
                height: _iconTileSize,
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: AppUtils.radiusSmall,
                ),
                child: Icon(icon, size: _iconSize, color: iconColor),
              ),
              const SizedBox(width: _iconGap),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: _titleInset),
                  child: Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: _messageGap),
          Text.rich(
            message,
            style: AppTextStyles.tableCell.copyWith(
              color: AppColors.dialogMessage,
            ),
          ),
          const SizedBox(height: _actionsGap),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: _actionSpacing,
            runSpacing: AppUtils.spacingSm,
            children: [
              AppSecondaryButton(
                label: AppStrings.cancel,
                onPressed: () => Navigator.of(context).pop(false),
              ),
              AppPrimaryButton(
                label: confirmLabel,
                compact: true,
                destructive: !positive,
                positive: positive,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
