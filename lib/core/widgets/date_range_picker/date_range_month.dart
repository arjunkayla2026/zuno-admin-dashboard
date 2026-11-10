import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/date_range_picker/date_range_day_cell.dart';

class DateRangeMonth extends StatelessWidget {
  const DateRangeMonth({
    super.key,
    required this.month,
    required this.firstDate,
    required this.lastDate,
    required this.today,
    required this.onDaySelected,
    required this.onDayHoverChanged,
    this.rangeStart,
    this.rangeEnd,
    this.leading = const [],
    this.trailing = const [],
  });

  static const int _daysPerWeek = 7;
  static const int _weeksShown = 6;
  static const double _navigationWidth = 60;
  static const double _headerGap = 8;
  static const double _weekdayHeight = 28;

  final DateTime month;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime today;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final ValueChanged<DateTime> onDaySelected;
  final void Function(DateTime day, bool isHovering) onDayHoverChanged;
  final List<Widget> leading;
  final List<Widget> trailing;

  DateRangeDayPosition _positionOf(DateTime day) {
    final start = rangeStart;
    final end = rangeEnd;
    if (start == null) return DateRangeDayPosition.none;
    if (end == null || DateUtils.isSameDay(start, end)) {
      return DateUtils.isSameDay(day, start)
          ? DateRangeDayPosition.single
          : DateRangeDayPosition.none;
    }
    if (DateUtils.isSameDay(day, start)) return DateRangeDayPosition.start;
    if (DateUtils.isSameDay(day, end)) return DateRangeDayPosition.end;
    return day.isAfter(start) && day.isBefore(end)
        ? DateRangeDayPosition.middle
        : DateRangeDayPosition.none;
  }

  Widget _cell(int dayNumber, int daysInMonth) {
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return const SizedBox(height: DateRangeDayCell.height);
    }
    final day = DateTime(month.year, month.month, dayNumber);
    return DateRangeDayCell(
      day: day,
      position: _positionOf(day),
      isEnabled: !day.isBefore(firstDate) && !day.isAfter(lastDate),
      isToday: DateUtils.isSameDay(day, today),
      onSelected: () => onDaySelected(day),
      onHoverChanged: (isHovering) => onDayHoverChanged(day, isHovering),
    );
  }

  Widget _navigation(List<Widget> buttons, MainAxisAlignment alignment) =>
      SizedBox(
        width: _navigationWidth,
        child: Row(mainAxisAlignment: alignment, children: buttons),
      );

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final offset = DateUtils.firstDayOffset(
      month.year,
      month.month,
      localizations,
    );
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _navigation(leading, MainAxisAlignment.start),
            Expanded(
              child: Text(
                localizations.formatMonthYear(month),
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMedium.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
            ),
            _navigation(trailing, MainAxisAlignment.end),
          ],
        ),
        const SizedBox(height: _headerGap),
        SizedBox(
          height: _weekdayHeight,
          child: Row(
            children: [
              for (var index = 0; index < _daysPerWeek; index++)
                Expanded(
                  child: Center(
                    child: Text(
                      localizations.narrowWeekdays[(localizations
                                  .firstDayOfWeekIndex +
                              index) %
                          _daysPerWeek],
                      style: AppTextStyles.tableFootnote.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        for (var week = 0; week < _weeksShown; week++)
          Row(
            children: [
              for (var index = 0; index < _daysPerWeek; index++)
                Expanded(
                  child: _cell(
                    week * _daysPerWeek + index - offset + 1,
                    daysInMonth,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
