import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dashed_divider.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_section_label.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';

class NotificationAudienceCard extends StatelessWidget {
  const NotificationAudienceCard({
    super.key,
    required this.status,
    required this.onRetry,
    this.error,
    this.users,
    this.hosts,
    this.hostLanguages = '',
  });

  static const double _labelGap = 10;
  static const double _rowGap = 8;
  static const double _totalGap = 10;
  static const double _noteGap = 14;
  static const EdgeInsets _padding = EdgeInsets.all(22);

  final LoadStatus status;
  final String? error;
  final VoidCallback onRetry;
  final int? users;
  final int? hosts;
  final String hostLanguages;

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
    final users = this.users;
    final hosts = this.hosts;
    final rows = [
      if (users != null)
        _row(
          AppStrings.usersLabel,
          NumberFormatter.grouped(users),
          label,
          value,
        ),
      if (hosts != null)
        _row(
          hostLanguages.isEmpty
              ? AppStrings.hostsLabel
              : AppStrings.hostsForLanguages(hostLanguages),
          NumberFormatter.grouped(hosts),
          label,
          value,
        ),
    ];

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
          child: switch (status) {
            LoadStatus.loading => const AppTableLoadingState(),
            LoadStatus.failure => AppTableErrorState(
              message: error ?? AppStrings.recordsLoadFailed,
              onRetry: onRetry,
            ),
            LoadStatus.loaded => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, row) in rows.indexed) ...[
                  if (index > 0) const SizedBox(height: _rowGap),
                  row,
                ],
                const SizedBox(height: _totalGap),
                const AppDashedDivider(),
                const SizedBox(height: _totalGap),
                _row(
                  AppStrings.totalRecipients,
                  NumberFormatter.grouped((users ?? 0) + (hosts ?? 0)),
                  AppTextStyles.bodySmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                  AppTextStyles.titleMedium.copyWith(color: textColor),
                ),
              ],
            ),
          },
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
