import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';

class AppInitialsAvatar extends StatelessWidget {
  const AppInitialsAvatar({
    super.key,
    required this.initials,
    required this.color,
    this.size = 34,
    this.borderRadius,
    this.textStyle,
  });

  final String initials;
  final Color color;
  final double size;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadius,
      ),
      child: Text(
        initials,
        style: (textStyle ?? AppTextStyles.labelSmall).copyWith(
          color: AppColors.white,
        ),
      ),
    );
  }
}
