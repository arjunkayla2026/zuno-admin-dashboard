import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class SurgePreviewNote extends StatelessWidget {
  const SurgePreviewNote({
    super.key,
    required this.percent,
    required this.start,
    required this.end,
  });

  static const double _iconSize = 15;
  static const double _iconGap = 10;
  static const double _iconTopInset = 2;
  static const EdgeInsets _padding = EdgeInsets.all(14);

  final int percent;
  final String start;
  final String end;

  @override
  Widget build(BuildContext context) {
    final muted = context.appColors.textSecondary;
    final textColor = context.colorScheme.onSurface;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: AppColors.statTileBackground,
        borderRadius: AppUtils.radiusSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: _iconTopInset),
            child: Icon(
              Icons.info_outline_rounded,
              size: _iconSize,
              color: muted,
            ),
          ),
          const SizedBox(width: _iconGap),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: AppStrings.surgePreviewLead),
                  TextSpan(
                    text: AppStrings.surgeUserLabel(percent),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: AppStrings.surgePreviewTail(start, end)),
                ],
              ),
              style: AppTextStyles.bodySmall.copyWith(color: muted),
            ),
          ),
        ],
      ),
    );
  }
}
