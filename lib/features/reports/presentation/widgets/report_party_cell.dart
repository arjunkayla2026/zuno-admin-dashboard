import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/user_report.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/widgets/report_labels.dart';

class ReportPartyCell extends StatelessWidget {
  const ReportPartyCell({super.key, required this.party});

  static const double _avatarSize = 28;
  static const double _avatarGap = 8;
  static const double _roleGap = 8;
  static const double _roleRadius = 5;
  static const double _detailsGap = 2;
  static const EdgeInsets _rolePadding = EdgeInsets.symmetric(
    horizontal: 7,
    vertical: 2,
  );

  final ReportParty party;

  @override
  Widget build(BuildContext context) {
    const palette = AppColors.avatarPalette;
    final colors = context.appColors;

    return Row(
      children: [
        AppInitialsAvatar(
          initials: party.initials,
          color: palette[party.avatarIndex % palette.length],
          size: _avatarSize,
          textStyle: AppTextStyles.captionSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: _avatarGap),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      party.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: _roleGap),
                  Container(
                    padding: _rolePadding,
                    decoration: BoxDecoration(
                      color: colors.inactiveBadge,
                      borderRadius: BorderRadius.circular(_roleRadius),
                    ),
                    child: Text(
                      ReportLabels.role(party.role),
                      style: AppTextStyles.captionSmall.copyWith(
                        color: colors.inactiveText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _detailsGap),
              Text(
                party.detailsLabel,
                style: AppTextStyles.captionSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
