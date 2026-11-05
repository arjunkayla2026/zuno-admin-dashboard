abstract final class DateFormatter {
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static String numeric(DateTime date) =>
      '${_twoDigits(date.month)}/${_twoDigits(date.day)}/${date.year}';

  static String short(DateTime date) =>
      '${_twoDigits(date.day)} ${_months[date.month - 1]} ${date.year}';

  static String long(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, ${short(date)}';
}
