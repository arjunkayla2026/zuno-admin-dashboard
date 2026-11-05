import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class AppPagination extends StatelessWidget {
  const AppPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  static const String _ellipsis = '…';
  static const double _gap = 4;
  static const int _neighbours = 1;

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  List<int?> get _visiblePages {
    final pages = <int?>[];
    for (var page = 1; page <= totalPages; page++) {
      final isVisible =
          page == 1 ||
          page == totalPages ||
          (page - currentPage).abs() <= _neighbours;
      if (isVisible) {
        pages.add(page);
      } else if (pages.last != null) {
        pages.add(null);
      }
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: _gap,
      runSpacing: _gap,
      children: [
        _PageButton(
          onPressed: currentPage > 1
              ? () => onPageChanged(currentPage - 1)
              : null,
          child: const Icon(Icons.chevron_left_rounded),
        ),
        for (final page in _visiblePages)
          if (page == null)
            const _PageButton(child: Text(_ellipsis))
          else
            _PageButton(
              selected: page == currentPage,
              onPressed: () => onPageChanged(page),
              child: Text('$page'),
            ),
        _PageButton(
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
          child: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.child,
    this.onPressed,
    this.selected = false,
  });

  static const double _size = 30;
  static const double _iconSize = 12;
  static const double _radius = 8;

  final Widget child;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    final color = selected
        ? AppColors.white
        : isDisabled
        ? AppColors.tableMutedText
        : context.colorScheme.onSurface;
    final radius = BorderRadius.circular(_radius);

    return Material(
      color: selected ? AppColors.paginationSelected : AppColors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Container(
          width: _size,
          height: _size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: selected
                ? null
                : Border.all(
                    color: isDisabled
                        ? AppColors.background
                        : AppColors.cardBorder,
                  ),
          ),
          child: IconTheme.merge(
            data: IconThemeData(size: _iconSize, color: color),
            child: DefaultTextStyle.merge(
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
