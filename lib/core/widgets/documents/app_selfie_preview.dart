import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';

class AppSelfiePreview extends StatelessWidget {
  const AppSelfiePreview({
    super.key,
    required this.initials,
    required this.avatarIndex,
    this.avatarSize = 64,
  });

  static const double _tintAlpha = 0.16;

  final String initials;
  final int avatarIndex;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    const palette = AppColors.avatarPalette;
    final color = palette[avatarIndex % palette.length];

    return ColoredBox(
      color: color.withValues(alpha: _tintAlpha),
      child: Center(
        child: AppInitialsAvatar(
          initials: initials,
          color: color,
          size: avatarSize,
          textStyle: AppTextStyles.headlineMedium,
        ),
      ),
    );
  }
}
