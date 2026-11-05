import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class AppLabeledTextField extends StatelessWidget {
  const AppLabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.suffix,
    this.onChanged,
    this.dense = false,
  });

  static const double _labelGap = 5;
  static const EdgeInsets _densePadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 9,
  );

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: textColor)),
        const SizedBox(height: _labelGap),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          style: AppTextStyles.fieldValue.copyWith(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            suffixIconConstraints: const BoxConstraints(),
            contentPadding: dense ? _densePadding : null,
          ),
        ),
      ],
    );
  }
}
