import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({super.key, required this.message});

  static const double _iconSize = 14;
  static const double _iconTopInset = 4;
  static const double _iconGap = 7;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: _padding,
        decoration: BoxDecoration(
          color: colors.errorBadge,
          borderRadius: BorderRadius.circular(AppTheme.radiusField),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: _iconTopInset),
              child: Icon(
                Icons.warning_amber_rounded,
                size: _iconSize,
                color: colors.errorText,
              ),
            ),
            const SizedBox(width: _iconGap),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.alertMessage.copyWith(
                  color: colors.errorText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
