import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_labels.dart';

class WithdrawalDetailsHeader extends StatelessWidget {
  const WithdrawalDetailsHeader({super.key, required this.withdrawal});

  static const double _avatarSize = 44;
  static const double _avatarGap = 12;

  final Withdrawal withdrawal;

  @override
  Widget build(BuildContext context) {
    const palette = AppColors.avatarPalette;
    final (statusLabel, status) = WithdrawalLabels.status(withdrawal);

    return Row(
      children: [
        AppInitialsAvatar(
          initials: withdrawal.initials,
          color: palette[withdrawal.avatarIndex % palette.length],
          size: _avatarSize,
        ),
        const SizedBox(width: _avatarGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                withdrawal.hostName,
                style: AppTextStyles.titleMedium.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              Text(
                AppStrings.dotSeparated(withdrawal.hostId, withdrawal.phone),
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
