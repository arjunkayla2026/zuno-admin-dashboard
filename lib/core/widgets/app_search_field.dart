import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.verticalPadding = 14,
  });

  static const double _iconSize = 16;
  static const double _iconSlotWidth = 34;

  final String hint;
  final ValueChanged<String> onChanged;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: AppUtils.radiusSmall,
      borderSide: const BorderSide(color: AppColors.cardBorder),
    );

    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.bodySmall.copyWith(
        color: context.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: context.appColors.formFieldHint,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: verticalPadding),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: _iconSize,
          color: context.appColors.formFieldHint,
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: _iconSlotWidth),
        border: border,
        enabledBorder: border,
      ),
    );
  }
}
