import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';

class SurgeSession {
  const SurgeSession({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.percent,
    required this.enabled,
  });

  factory SurgeSession.fromMap(int id, Object? data, {DateTime? today}) {
    final map = data is Map ? data : const {};
    final name = map[sessionNameField];
    final percent = map[surgeChargeField];
    final day = today ?? DateTime.now();
    return SurgeSession(
      id: id,
      name: name is String ? name.trim() : '',
      startTime: _readTime(map[startTimeField], day),
      endTime: _readTime(map[endTimeField], day),
      percent: percent is num ? percent.round() : 0,
      enabled: map[statusField] == enabledStatus,
    );
  }

  static const String listField = 'surgeCharge';
  static const String sessionNameField = 'sessionName';
  static const String startTimeField = 'startTime';
  static const String endTimeField = 'endTime';
  static const String surgeChargeField = 'surgeCharge';
  static const String statusField = 'status';
  static const String enabledStatus = 'enabled';
  static const String disabledStatus = 'disabled';
  static const int maxNameLength = 40;
  static const int minPercent = 1;
  static const int maxPercent = 99;
  static const int maxPercentDigits = 3;

  static final RegExp _wholeNumber = RegExp(r'^[0-9]+$');

  final int id;
  final String name;
  final DateTime? startTime;
  final DateTime? endTime;
  final int percent;
  final bool enabled;

  int? get startMinutes => _minutesOf(startTime);

  int? get endMinutes => _minutesOf(endTime);

  String get overlapMessage => AppStrings.surgeTimeOverlap(
    name,
    _clockOf(startMinutes),
    _clockOf(endMinutes),
  );

  static bool isValidPercent(int percent) =>
      percent >= minPercent && percent <= maxPercent;

  static int? parsePercent(String text) {
    final trimmed = text.trim();
    if (!_wholeNumber.hasMatch(trimmed)) return null;
    final percent = int.tryParse(trimmed);
    return percent != null && isValidPercent(percent) ? percent : null;
  }

  static bool windowsOverlap(int startA, int endA, int startB, int endB) {
    for (final (fromA, toA) in _spans(startA, endA)) {
      for (final (fromB, toB) in _spans(startB, endB)) {
        if (fromA < toB && fromB < toA) return true;
      }
    }
    return false;
  }

  static SurgeSession? firstOverlap(
    Iterable<SurgeSession> sessions, {
    required int startMinutes,
    required int endMinutes,
    int? skipId,
  }) {
    for (final session in sessions) {
      final start = session.startMinutes;
      final end = session.endMinutes;
      if (session.id == skipId || start == null || end == null) continue;
      if (windowsOverlap(startMinutes, endMinutes, start, end)) return session;
    }
    return null;
  }

  static List<(int, int)> _spans(int start, int end) => end > start
      ? [(start, end)]
      : [(start, Duration.minutesPerDay), (0, end)];

  static String _clockOf(int? minutes) => minutes == null
      ? AppStrings.emptyValue
      : DateFormatter.minutesOfDay(minutes);

  static List<SurgeSession> listFrom(Object? data, {DateTime? today}) => [
    if (data is List)
      for (final (index, entry) in data.indexed)
        SurgeSession.fromMap(index + 1, entry, today: today),
  ];

  static (DateTime, DateTime) timesOn(
    DateTime day,
    int startMinutes,
    int endMinutes,
  ) {
    final start = DateTime(day.year, day.month, day.day, 0, startMinutes);
    final endDay = endMinutes > startMinutes ? day.day : day.day + 1;
    return (start, DateTime(day.year, day.month, endDay, 0, endMinutes));
  }

  static int? _minutesOf(DateTime? time) =>
      time == null ? null : time.hour * Duration.minutesPerHour + time.minute;

  static DateTime? _readTime(Object? value, DateTime day) {
    if (value is Timestamp) return value.toDate();
    if (value is! num) return null;
    final minutes = value.toInt();
    if (minutes < 0 || minutes >= Duration.minutesPerDay) return null;
    return DateTime(day.year, day.month, day.day, 0, minutes);
  }

  static Timestamp? _writeTime(DateTime? time) =>
      time == null ? null : Timestamp.fromDate(time);

  Map<String, Object?> toMap() => {
    sessionNameField: name,
    startTimeField: _writeTime(startTime),
    endTimeField: _writeTime(endTime),
    surgeChargeField: percent,
    statusField: enabled ? enabledStatus : disabledStatus,
  };

  SurgeSession copyWith({
    int? id,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    int? percent,
    bool? enabled,
  }) {
    return SurgeSession(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      percent: percent ?? this.percent,
      enabled: enabled ?? this.enabled,
    );
  }
}
