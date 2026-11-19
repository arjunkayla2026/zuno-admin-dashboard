import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_user_photo_avatar.dart';

class AppAvatarNameCell extends StatelessWidget {
  const AppAvatarNameCell({
    super.key,
    required this.initials,
    required this.avatarIndex,
    required this.name,
    this.avatarSize = 30,
    this.imageUrl,
    this.photoUserId,
    this.badge,
  });

  static const double _gap = 10;
  static const double _badgeGap = 6;
  static final TextStyle _initialsStyle = AppTextStyles.captionSmall.copyWith(
    fontWeight: FontWeight.w700,
  );

  final String initials;
  final int avatarIndex;
  final String name;
  final double avatarSize;

  /// The profile picture, when the user record is already loaded.
  final String? imageUrl;

  /// Looks the profile picture up by this user or host ID instead.
  final String? photoUserId;

  /// Shown after the name, wrapping below it when space is short.
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    const palette = AppColors.avatarPalette;
    final nameText = Text(
      name,
      style: AppTextStyles.bodySmall.copyWith(
        color: context.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );

    return Row(
      children: [
        if (photoUserId case final userId?)
          AppUserPhotoAvatar(
            userId: userId,
            initials: initials,
            color: palette[avatarIndex % palette.length],
            size: avatarSize,
            textStyle: _initialsStyle,
          )
        else
          AppInitialsAvatar(
            initials: initials,
            color: palette[avatarIndex % palette.length],
            size: avatarSize,
            textStyle: _initialsStyle,
            imageUrl: imageUrl,
          ),
        const SizedBox(width: _gap),
        Expanded(
          child: switch (badge) {
            final badge? => Wrap(
              spacing: _badgeGap,
              runSpacing: _badgeGap,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [nameText, badge],
            ),
            null => nameText,
          },
        ),
      ],
    );
  }
}
