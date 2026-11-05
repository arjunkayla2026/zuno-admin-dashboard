import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

class EditUserProfile extends StatelessWidget {
  const EditUserProfile({super.key, required this.user});

  static const double _avatarSize = 56;
  static const double _avatarGap = 14;
  static const double _subtitleHeight = 1.1;

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.avatarPalette;

    return Row(
      children: [
        AppInitialsAvatar(
          initials: user.initials,
          color: palette[user.avatarIndex % palette.length],
          size: _avatarSize,
        ),
        const SizedBox(width: _avatarGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: AppTextStyles.cardTitle.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              Text(
                user.userId,
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
