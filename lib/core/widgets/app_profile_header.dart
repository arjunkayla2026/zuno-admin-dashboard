import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';

class AppProfileHeader extends StatelessWidget {
  const AppProfileHeader({
    super.key,
    required this.initials,
    required this.avatarIndex,
    required this.name,
    required this.subtitle,
  });

  static const double _avatarSize = 56;
  static const double _avatarGap = 14;
  static const double _subtitleHeight = 1.1;

  final String initials;
  final int avatarIndex;
  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    const palette = AppColors.avatarPalette;

    return Row(
      children: [
        AppInitialsAvatar(
          initials: initials,
          color: palette[avatarIndex % palette.length],
          size: _avatarSize,
        ),
        const SizedBox(width: _avatarGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.cardTitle.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.captionSmall.copyWith(
                  color: context.appColors.textSecondary,
                  height: _subtitleHeight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
