import 'package:cloud_firestore/cloud_firestore.dart';

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

  final int id;
  final String name;
  final DateTime? startTime;
  final DateTime? endTime;
  final int percent;
  final bool enabled;

  int? get startMinutes => _minutesOf(startTime);

  int? get endMinutes => _minutesOf(endTime);

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
