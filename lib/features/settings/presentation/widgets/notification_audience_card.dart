import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_section_label.dart';

class NotificationAudienceCard extends StatelessWidget {
  const NotificationAudienceCard({
    super.key,
    required this.users,
    required this.hosts,
  });

  static const double _labelGap = 10;
  static const double _rowGap = 8;
  static const double _totalGap = 10;
  static const double _noteGap = 14;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(16, 14, 16, 14);

  final int users;
  final int hosts;

  Widget _row(
    String label,
    String value,
    TextStyle labelStyle,
    TextStyle valueStyle,
  ) {
    return Row(
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        Text(value, style: valueStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final muted = context.appColors.textSecondary;
    final label = AppTextStyles.bodySmall.copyWith(color: muted);
    final value = AppTextStyles.bodySmall.copyWith(
      color: textColor,
      fontWeight: FontWeight.w700,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionLabel(AppStrings.audience),
        const SizedBox(height: _labelGap),
        Container(
          padding: _padding,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _row(
                AppStrings.usersLabel,
                NumberFormatter.grouped(users),
                label,
                value,
              ),
              const SizedBox(height: _rowGap),
              _row(
                AppStrings.hostsLabel,
                NumberFormatter.grouped(hosts),
                label,
                value,
              ),
              const SizedBox(height: _totalGap),
              const Divider(color: AppColors.cardBorder),
              const SizedBox(height: _totalGap),
              _row(
                AppStrings.totalRecipients,
                NumberFormatter.grouped(users + hosts),
                AppTextStyles.bodySmall.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
                AppTextStyles.titleMedium.copyWith(color: textColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: _noteGap),
        Text(
          AppStrings.audienceNote,
          style: AppTextStyles.tableFootnote.copyWith(color: muted),
        ),
      ],
    );
  }
}
