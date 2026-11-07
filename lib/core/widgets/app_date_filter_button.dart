import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/date_range_filter.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_options_menu.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';

class AppDateFilterButton extends StatelessWidget {
  const AppDateFilterButton({
    super.key,
    required this.value,
    required this.today,
    required this.onFilterSelected,
    required this.onCustomRangeSelected,
    this.customRange,
  });

  static const double height = 46;
  static const double _iconSize = 18;
  static final DateTime _firstDate = DateTime(2020);

  final DateRangeFilter value;
  final DateTime today;
  final DateTimeRange? customRange;
  final ValueChanged<DateRangeFilter> onFilterSelected;
  final ValueChanged<DateTimeRange> onCustomRangeSelected;

  static String _optionLabel(DateRangeFilter filter) => switch (filter) {
    DateRangeFilter.all => AppStrings.allDates,
    DateRangeFilter.yesterday => AppStrings.yesterday,
    DateRangeFilter.last7Days => AppStrings.last7Days,
    DateRangeFilter.last30Days => AppStrings.last30Days,
    DateRangeFilter.custom => AppStrings.customDateRange,
  };

  String get _buttonLabel {
    final range = customRange;
    return switch (value) {
      DateRangeFilter.all => AppStrings.filters,
      DateRangeFilter.custom when range != null => AppStrings.dateRangeLabel(
        DateFormatter.short(range.start),
        DateFormatter.short(range.end),
      ),
      final filter => _optionLabel(filter),
    };
  }

  Future<void> _open(BuildContext anchorContext) async {
    final selected = await showAppOptionsMenu<DateRangeFilter>(
      anchorContext: anchorContext,
      options: DateRangeFilter.values,
      labelOf: _optionLabel,
    );
    if (selected == null || !anchorContext.mounted) return;
    if (selected != DateRangeFilter.custom) {
      onFilterSelected(selected);
      return;
    }

    final range = await showDateRangePicker(
      context: anchorContext,
      firstDate: _firstDate,
      lastDate: today,
      initialDateRange:
          customRange ??
          DateTimeRange(
            start: today.subtract(const Duration(days: 6)),
            end: today,
          ),
    );
    if (range != null) onCustomRangeSelected(range);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Builder(
        builder: (anchorContext) => AppSecondaryButton(
          backgroundColor: context.colorScheme.surface,
          label: _buttonLabel,
          leading: const Icon(Icons.filter_list_rounded, size: _iconSize),
          onPressed: () => _open(anchorContext),
        ),
      ),
    );
  }
}
