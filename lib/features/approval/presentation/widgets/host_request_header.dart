import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/host_request.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/host_request_labels.dart';

class HostRequestHeader extends StatelessWidget {
  const HostRequestHeader({super.key, required this.request});

  static const double _avatarSize = 48;
  static const double _avatarRadius = 10;
  static const double _avatarGap = 12;

  final HostRequest request;

  @override
  Widget build(BuildContext context) {
    const palette = AppColors.avatarPalette;
    final (statusLabel, status) = HostRequestLabels.status(request.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppInitialsAvatar(
          initials: request.initials,
          color: palette[request.avatarIndex % palette.length],
          size: _avatarSize,
          borderRadius: BorderRadius.circular(_avatarRadius),
        ),
        const SizedBox(width: _avatarGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.realName,
                style: AppTextStyles.titleMedium.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              Text(
                AppStrings.nameAndCity(request.nickName, request.city),
                style: AppTextStyles.captionSmall.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        AppStatusBadge(label: statusLabel, status: status),
      ],
    );
  }
}
