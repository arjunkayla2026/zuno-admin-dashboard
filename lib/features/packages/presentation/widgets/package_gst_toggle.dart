import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class PackageGstToggle extends StatelessWidget {
  const PackageGstToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(12, 10, 10, 10);

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        borderRadius: AppUtils.radiusSmall,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.gstToggleTitle,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                Text(
                  AppStrings.gstToggleHelper,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppUtils.spacingMd),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
