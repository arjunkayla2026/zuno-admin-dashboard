import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class ViewAllButton extends StatelessWidget {
  const ViewAllButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  static const double _height = 30;
  static const double _iconSize = 16;
  static const double _radius = 8;

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme.onSurface;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, _height),
        padding: const EdgeInsets.symmetric(horizontal: AppUtils.spacingMd),
        foregroundColor: color,
        side: const BorderSide(color: AppColors.cardBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
          const SizedBox(width: AppUtils.spacingXs),
          Icon(Icons.chevron_right_rounded, size: _iconSize, color: color),
        ],
      ),
    );
  }
}
