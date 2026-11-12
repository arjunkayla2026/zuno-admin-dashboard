import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/name_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';

class CallParticipants extends StatelessWidget {
  const CallParticipants({super.key, required this.call});

  static const double _chevronSize = 16;
  static const double _gap = 14;

  final CallLog call;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: _gap,
      runSpacing: AppUtils.spacingSm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _Participant(
          name: call.userName,
          role: AppStrings.userRole,
          id: call.userDisplayId,
          avatarIndex: 0,
        ),
        Icon(
          Icons.chevron_right_rounded,
          size: _chevronSize,
          color: context.appColors.textSecondary,
        ),
        _Participant(
          name: call.hostName,
          role: AppStrings.hostRole,
          id: call.hostDisplayId,
          avatarIndex: NumberFormatter.parse(call.hostDisplayId),
        ),
      ],
    );
  }
}

class _Participant extends StatelessWidget {
  const _Participant({
    required this.name,
    required this.role,
    required this.id,
    required this.avatarIndex,
  });

  static const double _avatarSize = 30;
  static const double _avatarGap = 8;

  final String name;
  final String role;
  final String id;
  final int avatarIndex;

  @override
  Widget build(BuildContext context) {
    const palette = AppColors.avatarPalette;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppInitialsAvatar(
          initials: NameFormatter.initials(name),
          color: palette[avatarIndex % palette.length],
          size: _avatarSize,
        ),
        const SizedBox(width: _avatarGap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: AppTextStyles.labelSmall.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              AppStrings.participantRole(role, id),
              style: AppTextStyles.captionSmall.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
