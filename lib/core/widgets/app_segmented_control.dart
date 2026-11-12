import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_weight_stable_text.dart';

class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.segmentWidth,
  });

  static const double _padding = 3;
  static const double _segmentRadius = 8;
  static const double _segmentHeight = 32;
  static const double _segmentPadding = 12;
  static const double _segmentGap = 2;

  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;
  final double? segmentWidth;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(_segmentRadius);

    return Container(
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppUtils.radiusSmall,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Wrap(
        spacing: _segmentGap,
        children: [
          for (final MapEntry(key: option, value: label) in options.entries)
            Material(
              color: option == value
                  ? AppColors.primary
                  : AppColors.transparent,
              borderRadius: radius,
              child: InkWell(
                onTap: () => onChanged(option),
                borderRadius: radius,
                child: SizedBox(
                  width: segmentWidth,
                  height: _segmentHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _segmentPadding,
                    ),
                    child: Center(
                      widthFactor: 1,
                      child: AppWeightStableText(
                        label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: option == value
                              ? AppColors.onPrimaryButton
                              : AppColors.segmentText,
                          fontWeight: option == value
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        widestStyle: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
