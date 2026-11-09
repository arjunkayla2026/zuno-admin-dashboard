import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class AppChoiceChips<T> extends StatelessWidget {
  const AppChoiceChips({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.labelStyle,
  });

  static const double _gap = 6;

  final List<T> options;
  final Set<T> selected;
  final String Function(T option) labelOf;
  final ValueChanged<Set<T>> onChanged;
  final TextStyle? labelStyle;

  void _toggle(T option) {
    final next = {...selected};
    if (!next.remove(option)) next.add(option);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: _gap,
      runSpacing: _gap,
      children: [
        for (final option in options)
          _Chip(
            label: labelOf(option),
            selected: selected.contains(option),
            onTap: () => _toggle(option),
            labelStyle: labelStyle,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.labelStyle,
  });

  static const double _height = 30;
  static const double _iconSize = 14;
  static const double _iconGap = 5;
  static const EdgeInsets _padding = EdgeInsets.symmetric(horizontal: 12);

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final style = labelStyle ?? AppTextStyles.labelSmall;
    final color = selected
        ? AppColors.white
        : style.color ?? context.colorScheme.onSurface;

    return Material(
      color: selected ? AppColors.selectedOption : context.colorScheme.surface,
      borderRadius: AppUtils.radiusPill,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppUtils.radiusPill,
        child: Container(
          height: _height,
          padding: _padding,
          decoration: BoxDecoration(
            borderRadius: AppUtils.radiusPill,
            border: selected ? null : Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check_rounded, size: _iconSize, color: color),
                const SizedBox(width: _iconGap),
              ],
              Text(label, style: style.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
