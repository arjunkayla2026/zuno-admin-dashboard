import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.destructive = false,
    this.small = false,
    this.backgroundColor,
  });

  static const double _padding = 18;
  static const double _smallPadding = 10;
  static const double _smallHeight = 28;
  static const double _smallRadius = 8;

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool destructive;
  final bool small;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,

        minimumSize: Size(
          0,
          small ? _smallHeight : AppTheme.compactButtonHeight,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: small ? _smallPadding : _padding,
        ),
        foregroundColor: destructive
            ? colors.errorText
            : context.colorScheme.onSurface,
        textStyle: small
            ? AppTextStyles.tableFootnote.copyWith(fontWeight: FontWeight.w700)
            : AppTextStyles.compactButton,
        side: BorderSide(
          color: destructive ? colors.errorBadge : AppColors.cardBorder,
        ),
        shape: small
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallRadius),
              )
            : null,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading case final leading?) ...[
            leading,
            const SizedBox(width: AppUtils.spacingMd),
          ],
          Flexible(child: Text(label)),
        ],
      ),
    );
  }
}
