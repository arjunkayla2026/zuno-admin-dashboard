import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';

class AdminTopBar extends StatelessWidget {
  const AdminTopBar({
    super.key,
    required this.userName,
    required this.userRole,
    required this.userInitials,
    this.title,
    this.onMenuPressed,
  });

  static const double _height = 74;
  static const double _horizontalPadding = 32;
  static const double _compactPadding = 16;
  static const double _profileAvatarSize = 34;
  static const double _chevronSize = 20;
  static const double _chevronGap = 10;

  final String userName;
  final String userRole;
  final String userInitials;
  final String? title;
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final isCompact = !AppUtils.isDesktop(context);

    return Container(
      constraints: const BoxConstraints(minHeight: _height),
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? _compactPadding : _horizontalPadding,
        vertical: AppUtils.spacingSm,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: const Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          if (onMenuPressed != null)
            IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(Icons.menu_rounded),
            ),
          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                : Text(
                    title!,
                    style: AppTextStyles.pageTitle.copyWith(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
          ),
          if (!isCompact) ...[
            Text(
              DateFormatter.long(DateTime.now()),
              style: AppTextStyles.bodySmall.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppUtils.spacingLg),
          ],
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppUtils.spacingSm,
              vertical: AppUtils.spacingXs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppInitialsAvatar(
                  initials: userInitials,
                  color: AppColors.avatarNavy,
                  size: _profileAvatarSize,
                ),
                const SizedBox(width: AppUtils.spacingSm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: AppTextStyles.profileName.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      userRole,
                      style: AppTextStyles.captionSmall.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: _chevronGap),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: _chevronSize,
                  color: context.colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
