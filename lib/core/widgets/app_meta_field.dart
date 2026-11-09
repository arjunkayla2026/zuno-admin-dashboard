import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class AppMetaField extends StatelessWidget {
  const AppMetaField({
    super.key,
    required this.label,
    required this.minWidth,
    this.value,
    this.valueWidget,
    this.mono = false,
  }) : assert(value != null || valueWidget != null);

  static const double _labelGap = 2;

  final String label;
  final double minWidth;
  final String? value;
  final Widget? valueWidget;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: _labelGap),
          valueWidget ??
              Text(
                value!,
                style: mono
                    ? AppTextStyles.mono.copyWith(color: textColor)
                    : AppTextStyles.labelMedium.copyWith(color: textColor),
              ),
        ],
      ),
    );
  }
}
