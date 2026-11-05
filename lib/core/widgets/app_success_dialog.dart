import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';

Future<void> showAppSuccessDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String actionLabel,
}) {
  return showAppDialog<void>(
    context: context,
    builder: (_) => AppSuccessDialog(
      title: title,
      message: message,
      actionLabel: actionLabel,
    ),
  );
}

class AppSuccessDialog extends StatelessWidget {
  const AppSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
  });

  static const double _iconCircleSize = 72;
  static const double _iconSize = 38;
  static const double _actionWidth = 142;
  static const double _iconGap = 18;
  static const double _titleGap = 13;
  static const double _messageGap = 25;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(32, 34, 32, 29);

  final String title;
  final String message;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppDialogSurface(
      padding: _padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _iconCircleSize,
            height: _iconCircleSize,
            decoration: BoxDecoration(
              color: colors.activeBadge,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: _iconSize,
              color: colors.activeText,
            ),
          ),
          const SizedBox(height: _iconGap),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.pageTitle.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: _titleGap),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.tableCell.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: _messageGap),
          SizedBox(
            width: _actionWidth,
            child: AppPrimaryButton(
              label: actionLabel,
              compact: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
