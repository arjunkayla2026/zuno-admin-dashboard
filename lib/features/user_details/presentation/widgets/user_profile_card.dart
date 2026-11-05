import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/mock/user_details_mock_data.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/user_profile_menu_button.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

class UserProfileCard extends StatelessWidget {
  const UserProfileCard({super.key, required this.user});

  static const double _avatarSize = 82;
  static const double _avatarRadius = 16;
  static const double _avatarGap = 22;
  static const double _nameGap = 10;
  static const double _detailsGap = 8;
  static const double _metaLabelGap = 2;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(22, 20, 20, 20);

  final AdminUser user;

  (String, AppStatus) get _status => switch (user.status) {
    UserStatus.active ||
    UserStatus.newUser => (AppStrings.active, AppStatus.active),
    UserStatus.blocked => (AppStrings.blocked, AppStatus.blocked),
    UserStatus.deletedByAdmin => (
      AppStrings.deletedByAdmin,
      AppStatus.inactive,
    ),
    UserStatus.deletedByUser => (AppStrings.deletedByUser, AppStatus.inactive),
  };

  Widget _meta(
    BuildContext context,
    String label,
    String value, {
    required double width,
    bool mono = false,
  }) {
    final textColor = context.colorScheme.onSurface;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: width),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: _metaLabelGap),
          Text(
            value,
            style: mono
                ? AppTextStyles.mono.copyWith(color: textColor)
                : AppTextStyles.labelMedium.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.avatarPalette;
    final (statusLabel, status) = _status;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppInitialsAvatar(
            initials: user.initials,
            color: palette[user.avatarIndex % palette.length],
            size: _avatarSize,
            borderRadius: BorderRadius.circular(_avatarRadius),
            textStyle: AppTextStyles.headlineMedium,
          ),
          const SizedBox(width: _avatarGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: _nameGap,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      user.name,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    AppStatusBadge(label: statusLabel, status: status),
                  ],
                ),
                const SizedBox(height: _detailsGap),
                Wrap(
                  runSpacing: AppUtils.spacingSm,
                  children: [
                    _meta(
                      context,
                      AppStrings.userId,
                      user.userId,
                      width: 84,
                      mono: true,
                    ),
                    _meta(
                      context,
                      AppStrings.accountCreatedDate,
                      user.createdDate,
                      width: 152,
                    ),
                    _meta(
                      context,
                      AppStrings.phoneNumber,
                      user.phone,
                      width: 146,
                      mono: true,
                    ),
                    _meta(
                      context,
                      AppStrings.lastOnline,
                      UserDetailsMockData.lastOnline,
                      width: 160,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (user.hasActions) const UserProfileMenuButton(),
        ],
      ),
    );
  }
}
