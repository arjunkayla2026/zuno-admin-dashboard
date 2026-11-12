import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';

class TotalCallsCard extends StatelessWidget {
  const TotalCallsCard({super.key, required this.count});

  static const double _height = 42;
  static const double _gap = 16;
  static const EdgeInsets _padding = EdgeInsets.symmetric(horizontal: 18);

  final int? count;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;

    return Container(
      height: _height,
      padding: _padding,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppUtils.radiusSmall,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.totalCalls,
            style: AppTextStyles.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: _gap),
          Text(
            count == null
                ? AppStrings.emptyValue
                : NumberFormatter.grouped(count!),
            style: AppTextStyles.statValue.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
