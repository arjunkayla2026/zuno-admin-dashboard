import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/models/user_stat.dart';

class UserStatCards extends StatelessWidget {
  const UserStatCards({super.key, required this.stats});

  static const double _gap = 14;
  static const double _minWidth = 150;
  static const double _minHeight = 97;
  static const double _labelHeight = 36;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );

  final List<UserStat> stats;

  @override
  Widget build(BuildContext context) {
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
                constraints: const BoxConstraints(minHeight: _minHeight),
                padding: _padding,
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: AppUtils.radiusSmall,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: _labelHeight,
                      ),
                      child: Text(
                        stat.label,
                        style: AppTextStyles.tableFootnote.copyWith(
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      stat.value,
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
