import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';

class AppAvatarNameCell extends StatelessWidget {
  const AppAvatarNameCell({
    super.key,
    required this.initials,
    required this.avatarIndex,
    required this.name,
    this.avatarSize = 30,
  });

  static const double _gap = 10;

  final String initials;
  final int avatarIndex;
  final String name;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    const palette = AppColors.avatarPalette;

    return Row(
      children: [
        AppInitialsAvatar(
          initials: initials,
          color: palette[avatarIndex % palette.length],
          size: avatarSize,
          textStyle: AppTextStyles.captionSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: _gap),
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
