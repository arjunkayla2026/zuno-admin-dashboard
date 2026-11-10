import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/payout_request.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/payout_request_labels.dart';

class PayoutRequestHeader extends StatelessWidget {
  const PayoutRequestHeader({super.key, required this.payout});

  static const double _avatarSize = 56;
  static const double _avatarGap = 14;

  final PayoutRequest payout;

  @override
  Widget build(BuildContext context) {
    const palette = AppColors.avatarPalette;
    final (statusLabel, status) = PayoutRequestLabels.status(payout.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppInitialsAvatar(
          initials: payout.initials,
          color: palette[payout.avatarIndex % palette.length],
          size: _avatarSize,
        ),
        const SizedBox(width: _avatarGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payout.hostName,
                style: AppTextStyles.titleMedium.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              Text(
                payout.userID,
                style: AppTextStyles.monoSmall.copyWith(
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
