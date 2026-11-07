import 'package:zuno_admin_dashboard/features/surge_charge_sessions/data/models/surge_session.dart';

abstract final class SurgeSessionMockData {
  static const int _minutesPerHour = Duration.minutesPerHour;

  static const int defaultStartMinutes = 20 * _minutesPerHour;
  static const int defaultEndMinutes = 23 * _minutesPerHour;

  static const List<SurgeSession> sessions = [
    SurgeSession(
      id: 1,
      startMinutes: 19 * _minutesPerHour,
      endMinutes: 22 * _minutesPerHour,
      percent: 20,
      enabled: true,
    ),
    SurgeSession(
      id: 2,
      startMinutes: 22 * _minutesPerHour,
      endMinutes: 23 * _minutesPerHour + 59,
      percent: 30,
      enabled: true,
    ),
    SurgeSession(
      id: 3,
      startMinutes: 12 * _minutesPerHour,
      endMinutes: 14 * _minutesPerHour,
      percent: 10,
      enabled: false,
    ),
  ];
}
