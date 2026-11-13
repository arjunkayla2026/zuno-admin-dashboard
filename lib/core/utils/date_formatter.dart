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
      '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';

  static String short(DateTime date) =>
      '${_twoDigits(date.day)} ${_months[date.month - 1]} ${date.year}';

  static String time(DateTime date) => clock(date.hour, date.minute);

  static String clock(int hour, int minute) {
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    return '${_twoDigits(displayHour)}:${_twoDigits(minute)} $period';
  }

  static String timeWithSeconds(DateTime date) {
    final displayHour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '${_twoDigits(displayHour)}:${_twoDigits(date.minute)}:'
        '${_twoDigits(date.second)} $period';
  }

  static String shortDuration(int seconds) {
    final minutes = seconds ~/ Duration.secondsPerMinute;
    final remainder = seconds % Duration.secondsPerMinute;
    if (minutes == 0) return '${remainder}s';
    return '${minutes}m ${remainder}s';
  }

  static String minutesOfDay(int minutes) => clock(
    minutes ~/ Duration.minutesPerHour,
    minutes % Duration.minutesPerHour,
  );

  static String long(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, ${short(date)}';
}
