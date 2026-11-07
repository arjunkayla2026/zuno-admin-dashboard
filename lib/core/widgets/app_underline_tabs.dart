import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class AppUnderlineTabs<T> extends StatelessWidget {
  const AppUnderlineTabs({
    super.key,
    required this.tabs,
    required this.value,
    required this.onChanged,
    this.counts,
  });

  final Map<T, String> tabs;
  final T value;
  final ValueChanged<T> onChanged;
  final Map<T, int>? counts;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (final MapEntry(key: tab, value: label) in tabs.entries)
          _UnderlineTab(
            label: label,
            count: counts?[tab],
            selected: tab == value,
            onTap: () => onChanged(tab),
          ),
      ],
    );
  }
}

class _UnderlineTab extends StatelessWidget {
  const _UnderlineTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  static const double _height = 44;
  static const double _sidePadding = 17;
  static const double _countGap = 8;
  static const double _underline = 2;
  static const double _countRadius = 5;
  static const EdgeInsets _countPadding = EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 1,
  );

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: _height,
        padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.primary : AppColors.transparent,
              width: _underline,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: selected
                    ? context.colorScheme.onSurface
                    : colors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (count case final count?) ...[
              const SizedBox(width: _countGap),
              Container(
                padding: _countPadding,
                decoration: BoxDecoration(
                  color: colors.inactiveBadge,
                  borderRadius: BorderRadius.circular(_countRadius),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: colors.inactiveText,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
