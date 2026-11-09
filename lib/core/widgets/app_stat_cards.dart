import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class AppStat {
  const AppStat({required this.label, required this.value, this.unit});

  final String label;
  final String value;
  final String? unit;
}

class AppStatCards extends StatelessWidget {
  const AppStatCards({
    super.key,
    required this.stats,
    this.dense = false,
    this.filled = false,
  });

  static const double _gap = 14;
  static const double _minWidth = 150;
  static const double _minHeight = 97;
  static const double _denseMinHeight = 76;
  static const double _labelHeight = 36;
  static const double _denseLabelHeight = 22;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );

  final List<AppStat> stats;
  final bool dense;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final muted = context.appColors.textSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final columns = ((maxWidth + _gap) / (_minWidth + _gap)).floor().clamp(
          1,
          stats.length,
        );
        final width = (maxWidth - _gap * (columns - 1)) / columns;

        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final stat in stats)
              Container(
                width: width,
                constraints: BoxConstraints(
                  minHeight: dense ? _denseMinHeight : _minHeight,
                ),
                padding: _padding,
                decoration: BoxDecoration(
                  color: filled
                      ? AppColors.statTileBackground
                      : context.colorScheme.surface,
                  borderRadius: AppUtils.radiusSmall,
                  border: filled
                      ? null
                      : Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: dense ? _denseLabelHeight : _labelHeight,
                      ),
                      child: Text(
                        stat.label,
                        style: AppTextStyles.tableFootnote.copyWith(
                          color: muted,
                        ),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: stat.value),
                          if (stat.unit case final unit?)
                            TextSpan(
                              text: ' $unit',
                              style: AppTextStyles.captionSmall.copyWith(
                                color: muted,
                              ),
                            ),
                        ],
                      ),
                      style: AppTextStyles.statValue.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
