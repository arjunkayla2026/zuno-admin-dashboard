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
    this.small = false,
    this.destructive = false,
    this.tonal = false,
    this.positive = false,
  });

  static const double _compactPadding = 18;
  static const double _smallPadding = 10;
  static const double _smallHeight = 28;
  static const double _smallRadius = 8;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool compact;
  final bool small;
  final bool destructive;
  final bool tonal;
  final bool positive;

  bool get _shrinks => compact || small;

  Color? _background(BuildContext context) {
    if (destructive) return context.appColors.errorText;
    if (positive) return context.appColors.activeText;
    if (tonal) return context.appColors.primarySoft;
    return null;
  }

  Color? _foreground(BuildContext context) {
    if (destructive || positive) return AppColors.white;
    if (tonal) return context.colorScheme.onSurface;
    return null;
  }

  Size? get _minimumSize {
    if (small) return const Size(0, _smallHeight);
    if (compact) return const Size(0, AppTheme.compactButtonHeight);
    return null;
  }

  EdgeInsets? get _padding {
    if (small) return const EdgeInsets.symmetric(horizontal: _smallPadding);
    if (compact) return const EdgeInsets.symmetric(horizontal: _compactPadding);
    return null;
  }

  TextStyle? get _textStyle {
    if (small) {
      return AppTextStyles.tableFootnote.copyWith(fontWeight: FontWeight.w700);
    }
    if (compact) return AppTextStyles.compactButton;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon == null ? null : Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: _minimumSize,
        padding: _padding,
        textStyle: _textStyle,
        tapTargetSize: _shrinks ? MaterialTapTargetSize.shrinkWrap : null,
        backgroundColor: _background(context),
        foregroundColor: _foreground(context),
        shape: small
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallRadius),
              )
            : null,
      ),
    );

    if (_shrinks) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
