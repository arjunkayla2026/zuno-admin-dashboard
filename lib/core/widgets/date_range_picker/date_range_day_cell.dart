import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';

enum DateRangeDayPosition { none, single, start, middle, end }

class DateRangeDayCell extends StatelessWidget {
  const DateRangeDayCell({
    super.key,
    required this.day,
    required this.position,
    required this.isEnabled,
    required this.isToday,
    required this.onSelected,
    required this.onHoverChanged,
  });

  static const double height = 36;
  static const double _circleSize = 34;
  static const double _bandInset = 1;
  static const double _halfWidth = 0.5;

  final DateTime day;
  final DateRangeDayPosition position;
  final bool isEnabled;
  final bool isToday;
  final VoidCallback onSelected;
  final ValueChanged<bool> onHoverChanged;

  bool get _isEndpoint => switch (position) {
    DateRangeDayPosition.single ||
    DateRangeDayPosition.start ||
    DateRangeDayPosition.end => true,
    DateRangeDayPosition.none || DateRangeDayPosition.middle => false,
  };

  Widget? _band(BuildContext context) {
    final (alignment, widthFactor) = switch (position) {
      DateRangeDayPosition.start => (Alignment.centerRight, _halfWidth),
      DateRangeDayPosition.end => (Alignment.centerLeft, _halfWidth),
      DateRangeDayPosition.middle => (Alignment.center, 1.0),
      DateRangeDayPosition.none || DateRangeDayPosition.single => (null, 0.0),
    };
    if (alignment == null) return null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _bandInset),
      child: FractionallySizedBox(
        alignment: alignment,
        widthFactor: widthFactor,
        child: ColoredBox(color: context.appColors.primarySoft),
      ),
    );
  }

  Color _textColor(BuildContext context) {
    if (_isEndpoint) return context.colorScheme.onPrimary;
    if (!isEnabled) return context.appColors.textTertiary;
    return context.colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final band = _band(context);
    final primary = context.colorScheme.primary;

    return Semantics(
      button: true,
      enabled: isEnabled,
      selected: position != DateRangeDayPosition.none,
      label: DateFormatter.short(day),
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (band != null) Positioned.fill(child: band),
            SizedBox.square(
              dimension: _circleSize,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  hoverColor: _isEndpoint
                      ? primary
                      : context.appColors.primarySoft,
                  onTap: isEnabled ? onSelected : null,
                  onHover: isEnabled ? onHoverChanged : null,
                  child: Ink(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isEndpoint ? primary : null,
                      border: isToday && !_isEndpoint
                          ? Border.all(color: primary)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: AppTextStyles.tableCell.copyWith(
                          color: _textColor(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
