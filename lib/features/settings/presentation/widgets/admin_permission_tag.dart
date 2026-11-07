import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class AdminPermissionTag extends StatelessWidget {
  const AdminPermissionTag({
    super.key,
    required this.label,
    this.highlighted = false,
  });

  static const double _radius = 4;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 3,
  );

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: highlighted ? colors.primarySoft : AppColors.background,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionSmall.copyWith(
          color: highlighted
              ? colors.onPrimarySoft
              : context.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
