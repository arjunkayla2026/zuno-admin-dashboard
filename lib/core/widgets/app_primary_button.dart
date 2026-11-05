import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.compact = false,
    this.destructive = false,
  });

  static const double _compactPadding = 18;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool compact;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon == null ? null : Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: compact
            ? const Size(0, AppTheme.compactButtonHeight)
            : null,
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: _compactPadding)
            : null,
        textStyle: compact ? AppTextStyles.compactButton : null,
        tapTargetSize: compact ? MaterialTapTargetSize.shrinkWrap : null,
        backgroundColor: destructive ? context.appColors.errorText : null,
        foregroundColor: destructive ? AppColors.white : null,
      ),
    );

    if (compact) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
