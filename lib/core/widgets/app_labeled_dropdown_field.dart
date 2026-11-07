import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';

class AppLabeledDropdownField<T> extends StatelessWidget {
  const AppLabeledDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
    this.labelStyle,
  });

  static const double _labelGap = 5;
  static const double _iconSize = 20;

  final String label;
  final String hint;
  final T? value;
  final List<T> options;
  final String Function(T option) labelOf;
  final ValueChanged<T?> onChanged;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              labelStyle ?? AppTextStyles.labelSmall.copyWith(color: textColor),
        ),
        const SizedBox(height: _labelGap),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          onChanged: onChanged,
          style: AppTextStyles.fieldValue.copyWith(color: textColor),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: _iconSize,
            color: context.appColors.textSecondary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: AppLabeledTextField.densePadding,
          ),
          items: [
            for (final option in options)
              DropdownMenuItem<T>(value: option, child: Text(labelOf(option))),
          ],
        ),
      ],
    );
  }
}
