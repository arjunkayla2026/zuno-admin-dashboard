import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_anchored_menu.dart';
import 'package:zuno_admin_dashboard/core/widgets/date_range_picker/date_range_footer.dart';
import 'package:zuno_admin_dashboard/core/widgets/date_range_picker/date_range_month.dart';

const double _wideWidth = 572;
const double _narrowWidth = 292;
const double _wideHeight = 396;
const double _narrowHeight = 428;

Future<DateTimeRange?> showAppDateRangePicker({
  required BuildContext anchorContext,
  required DateTime firstDate,
  required DateTime lastDate,
  required DateTime today,
  DateTimeRange? initialRange,
}) {
  final screen = MediaQuery.sizeOf(anchorContext);
  final isWide = !AppUtils.isMobile(anchorContext);
  final maxWidth = screen.width - AppUtils.spacingSm * 2;
  final maxHeight = screen.height - AppUtils.spacingSm * 2;
  final size = Size(
    min(isWide ? _wideWidth : _narrowWidth, maxWidth),
    min(isWide ? _wideHeight : _narrowHeight, maxHeight),
  );

  return showAnchoredMenu<DateTimeRange>(
    anchorContext: anchorContext,
    size: size,
    position: (anchor) =>
        Offset(anchor.right - size.width, anchor.bottom + AppUtils.spacingSm),
    builder: (_) => AppDateRangePicker(
      firstDate: firstDate,
      lastDate: lastDate,
      today: today,
      initialRange: initialRange,
      monthsShown: isWide ? 2 : 1,
    ),
  );
}

class AppDateRangePicker extends StatefulWidget {
  const AppDateRangePicker({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.today,
    this.initialRange,
    this.monthsShown = 2,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime today;
  final DateTimeRange? initialRange;
  final int monthsShown;

  @override
  State<AppDateRangePicker> createState() => _AppDateRangePickerState();
}

class _AppDateRangePickerState extends State<AppDateRangePicker> {
  static const int _monthsPerYear = 12;
  static const double _monthGap = 28;
  static const double _footerGap = 12;
  static const double _navigationIconSize = 18;
  static const double _navigationButtonSize = 28;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(20, 16, 20, 16);

  late final DateTime _firstDate = DateUtils.dateOnly(widget.firstDate);
  late final DateTime _lastDate = DateUtils.dateOnly(widget.lastDate);
  late final DateTime _firstMonth = DateUtils.dateOnly(
    DateTime(_firstDate.year, _firstDate.month),
  );
  late final DateTime _lastVisibleMonth = _clampMonth(
    DateUtils.addMonthsToMonthDate(
      DateTime(_lastDate.year, _lastDate.month),
      1 - widget.monthsShown,
    ),
    DateTime(_lastDate.year, _lastDate.month),
  );

  late DateTime _visibleMonth;
  DateTime? _start;
  DateTime? _end;
  DateTime? _hovered;

  bool get _isChoosingEnd => _start != null && _end == null;

  DateTime _clampMonth(DateTime month, DateTime latest) {
    if (month.isBefore(_firstMonth)) return _firstMonth;
    return month.isAfter(latest) ? latest : month;
  }

  @override
  void initState() {
    super.initState();
    final range = widget.initialRange;
    if (range != null) {
      _start = DateUtils.dateOnly(range.start);
      _end = DateUtils.dateOnly(range.end);
    }
    final focus = _end ?? _lastDate;
    _visibleMonth = _clampMonth(
      DateUtils.addMonthsToMonthDate(
        DateTime(focus.year, focus.month),
        1 - widget.monthsShown,
      ),
      _lastVisibleMonth,
    );
  }

  void _selectDay(DateTime day) => setState(() {
    final start = _start;
    _hovered = null;
    if (start == null || _end != null) {
      _start = day;
      _end = null;
    } else if (day.isBefore(start)) {
      _start = day;
      _end = start;
    } else {
      _end = day;
    }
  });

  void _hoverDay(DateTime day, bool isHovering) {
    if (!_isChoosingEnd) return;
    if (isHovering) {
      setState(() => _hovered = day);
    } else if (_hovered == day) {
      setState(() => _hovered = null);
    }
  }

  void _moveBy(int months) => setState(
    () => _visibleMonth = _clampMonth(
      DateUtils.addMonthsToMonthDate(_visibleMonth, months),
      _lastVisibleMonth,
    ),
  );

  Widget _navigationButton({
    required IconData icon,
    required String tooltip,
    required int months,
  }) {
    final canMove = months < 0
        ? _visibleMonth.isAfter(_firstMonth)
        : _visibleMonth.isBefore(_lastVisibleMonth);

    return IconButton(
      icon: Icon(icon),
      iconSize: _navigationIconSize,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size.square(_navigationButtonSize),
        fixedSize: const Size.square(_navigationButtonSize),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: canMove ? () => _moveBy(months) : null,
    );
  }

  List<Widget> get _backButtons => [
    _navigationButton(
      icon: Icons.keyboard_double_arrow_left_rounded,
      tooltip: AppStrings.previousYear,
      months: -_monthsPerYear,
    ),
    _navigationButton(
      icon: Icons.chevron_left_rounded,
      tooltip: AppStrings.previousMonth,
      months: -1,
    ),
  ];

  List<Widget> get _forwardButtons => [
    _navigationButton(
      icon: Icons.chevron_right_rounded,
      tooltip: AppStrings.nextMonth,
      months: 1,
    ),
    _navigationButton(
      icon: Icons.keyboard_double_arrow_right_rounded,
      tooltip: AppStrings.nextYear,
      months: _monthsPerYear,
    ),
  ];

  Widget _month(int index, DateTime? rangeStart, DateTime? rangeEnd) {
    return DateRangeMonth(
      month: DateUtils.addMonthsToMonthDate(_visibleMonth, index),
      firstDate: _firstDate,
      lastDate: _lastDate,
      today: DateUtils.dateOnly(widget.today),
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      onDaySelected: _selectDay,
      onDayHoverChanged: _hoverDay,
      leading: index == 0 ? _backButtons : const [],
      trailing: index == widget.monthsShown - 1 ? _forwardButtons : const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final start = _start;
    final previewEnd = _end ?? _hovered;
    final isReversed =
        start != null && previewEnd != null && previewEnd.isBefore(start);
    final rangeStart = isReversed ? previewEnd : start;
    final rangeEnd = isReversed ? start : previewEnd;
    final end = _end;

    return SingleChildScrollView(
      padding: _padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < widget.monthsShown; index++) ...[
                if (index > 0) const SizedBox(width: _monthGap),
                Expanded(child: _month(index, rangeStart, rangeEnd)),
              ],
            ],
          ),
          const SizedBox(height: _footerGap),
          const Divider(height: 1),
          const SizedBox(height: _footerGap),
          DateRangeFooter(
            start: start,
            end: end,
            onCancel: () => Navigator.of(context).pop(),
            onApply: start == null || end == null
                ? null
                : () =>
                      Navigator.of(context)
                          .pop(DateTimeRange(start: start, end: end)),
          ),
        ],
      ),
    );
  }
}
