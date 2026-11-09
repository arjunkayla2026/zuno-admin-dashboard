import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_meta_field.dart';

class AppDetailItem {
  const AppDetailItem(this.label, {this.value, this.child, this.mono = false})
    : assert(value != null || child != null);

  final String label;
  final String? value;
  final Widget? child;
  final bool mono;
}

class AppDetailGrid extends StatelessWidget {
  const AppDetailGrid({super.key, required this.items, this.columns = 2});

  static const double _columnGap = 16;
  static const double _rowGap = 12;

  final List<AppDetailItem> items;
  final int columns;

  Widget _field(BuildContext context, AppDetailItem item) {
    final textColor = context.colorScheme.onSurface;
    final style = item.mono
        ? AppTextStyles.monoSmall.copyWith(color: textColor)
        : AppTextStyles.labelMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          );

    return AppMetaField(
      label: item.label,
      minWidth: 0,
      valueWidget: item.child ?? Text(item.value!, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var start = 0; start < items.length; start += columns) ...[
          if (start > 0) const SizedBox(height: _rowGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var offset = 0; offset < columns; offset++) ...[
                if (offset > 0) const SizedBox(width: _columnGap),
                Expanded(
                  child: start + offset < items.length
                      ? _field(context, items[start + offset])
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
