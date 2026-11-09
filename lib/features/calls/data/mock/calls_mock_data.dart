import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';

abstract final class CallsMockData {
  static final DateTime today = DateTime(2026, 11, 4);

  static const String _endedByUser = 'User';
  static const String _endedByHost = 'Host';
  static const String _noAnswer = 'System – no answer';
  static const String _lowBalance = 'System – low balance';
  static const String _hostBusy = 'System – host busy';

  static const int _todayCount = 46;
  static const int _olderCount = 18;

  static const List<String> _users = [
    'Rahul Menon',
    'Vishnu Das',
    'Akhil Kumar',
    'Sanjay Rao',
    'Faisal Muhammed',
    'Kiran Babu',
    'Arjun Nair',
    'Midhun Raj',
  ];
  static const List<String> _hosts = [
    'Nandana',
    'Meera',
    'Neena',
    'Jenniffer',
    'Pinkky',
    'Anjali',
    'Kavya',
    'Sneha',
  ];

  static DateTime _at(DateTime day, int hour, int minute, int second) =>
      DateTime(day.year, day.month, day.day, hour, minute, second);

  static CallLog _call({
    required DateTime day,
    required int index,
    required String user,
    required String host,
    required CallLogType type,
    required (int, int, int) initiated,
    required int ringSeconds,
    required int? talkSeconds,
    required String endedBy,
    required CallLogStatus status,
    String? userId,
    String? hostId,
    String? callId,
    String? sessionId,
  }) {
    final (hour, minute, second) = initiated;
    final initiatedAt = _at(day, hour, minute, second);
    final startedAt = talkSeconds == null
        ? null
        : initiatedAt.add(Duration(seconds: ringSeconds));
    final endedAt = (startedAt ?? initiatedAt).add(
      Duration(seconds: talkSeconds ?? ringSeconds),
    );
    return CallLog(
      callId: callId ?? 'CL${784600 + index * 7}',
      sessionId:
          sessionId ?? 'SES-${(0x4b28b500 + index * 0x1f3d).toRadixString(16)}',
      userName: user,
      userId: userId ?? 'ZU${10231 + index}',
      userPhone: '+91 9${(80000000 + index * 7919).toString().padLeft(9, '0')}',
      hostName: host,
      hostId: hostId ?? 'ZH${10290 + index % 12}',
      type: type,
      initiatedAt: initiatedAt,
      startedAt: startedAt,
      endedAt: endedAt,
      endedBy: endedBy,
      status: status,
    );
  }

  static final List<CallLog> _screenshotCalls = [
    _call(
      day: today,
      index: 0,
      user: 'Sanjay Rao',
      host: 'Nandana',
      type: CallLogType.audio,
      initiated: (21, 39, 9),
      ringSeconds: 7,
      talkSeconds: 590,
      endedBy: _endedByUser,
      status: CallLogStatus.completed,
    ),
    _call(
      day: today,
      index: 1,
      user: 'Kiran Babu',
      host: 'Neena',
      type: CallLogType.video,
      initiated: (20, 50, 24),
      ringSeconds: 18,
      talkSeconds: 47,
      endedBy: _endedByHost,
      status: CallLogStatus.completed,
    ),
    _call(
      day: today,
      index: 2,
      user: 'Suhail Ahmed',
      host: 'Aishu',
      type: CallLogType.video,
      initiated: (20, 5, 32),
      ringSeconds: 22,
      talkSeconds: 272,
      endedBy: _endedByHost,
      status: CallLogStatus.completed,
    ),
    _call(
      day: today,
      index: 3,
      user: 'Akhil Kumar',
      host: 'Sneha',
      type: CallLogType.audio,
      initiated: (19, 51, 12),
      ringSeconds: 22,
      talkSeconds: null,
      endedBy: _endedByUser,
      status: CallLogStatus.missed,
    ),
    _call(
      day: today,
      index: 4,
      user: 'Faisal Muhammed',
      host: 'Neena',
      type: CallLogType.audio,
      initiated: (18, 53, 47),
      ringSeconds: 30,
      talkSeconds: null,
      endedBy: _noAnswer,
      status: CallLogStatus.notAnswered,
    ),
    _call(
      day: today,
      index: 5,
      user: 'Midhun Raj',
      host: 'Anjali',
      type: CallLogType.audio,
      initiated: (14, 36, 2),
      ringSeconds: 20,
      talkSeconds: 501,
      endedBy: _endedByUser,
      status: CallLogStatus.completed,
    ),
    _call(
      day: today,
      index: 6,
      user: 'Vishnu Das',
      host: 'Neena',
      type: CallLogType.audio,
      initiated: (14, 34, 34),
      ringSeconds: 15,
      talkSeconds: 73,
      endedBy: _lowBalance,
      status: CallLogStatus.lowBalance,
    ),
    _call(
      day: today,
      index: 7,
      user: 'Tarun Singh',
      host: 'Sana',
      type: CallLogType.video,
      initiated: (14, 29, 10),
      ringSeconds: 15,
      talkSeconds: 814,
      endedBy: _endedByUser,
      status: CallLogStatus.completed,
    ),
    _call(
      day: today,
      index: 8,
      user: 'Joel Thomas',
      host: 'Jenniffer',
      type: CallLogType.audio,
      initiated: (14, 28, 42),
      ringSeconds: 21,
      talkSeconds: 1397,
      endedBy: _endedByUser,
      status: CallLogStatus.completed,
    ),
    _call(
      day: today,
      index: 9,
      user: 'Arjun Nair',
      host: 'Jenniffer',
      type: CallLogType.audio,
      initiated: (12, 14, 11),
      ringSeconds: 30,
      talkSeconds: null,
      endedBy: _noAnswer,
      status: CallLogStatus.notAnswered,
    ),
    _call(
      day: today,
      index: 10,
      user: 'Vishnu Das',
      host: 'Meera',
      type: CallLogType.audio,
      initiated: (12, 5, 38),
      ringSeconds: 6,
      talkSeconds: 683,
      endedBy: _endedByHost,
      status: CallLogStatus.completed,
    ),
    _call(
      day: today,
      index: 11,
      user: 'Anand Krishnan',
      host: 'Divya',
      type: CallLogType.audio,
      initiated: (11, 50, 0),
      ringSeconds: 9,
      talkSeconds: null,
      endedBy: _endedByUser,
      status: CallLogStatus.missed,
    ),
  ];

  static const List<(CallLogStatus, String, int?)> _outcomes = [
    (CallLogStatus.completed, _endedByUser, 245),
    (CallLogStatus.busy, _hostBusy, null),
    (CallLogStatus.completed, _endedByHost, 132),
    (CallLogStatus.rejected, _endedByHost, null),
    (CallLogStatus.notAnswered, _noAnswer, null),
    (CallLogStatus.lowBalance, _lowBalance, 96),
    (CallLogStatus.missed, _endedByUser, null),
  ];

  static CallLog _generated(DateTime day, int index) {
    final (status, endedBy, talkSeconds) = _outcomes[index % _outcomes.length];
    final minuteOfDay = 11 * 60 + 40 - index * 13;
    final clamped = minuteOfDay < 0 ? minuteOfDay + 24 * 60 : minuteOfDay;
    return _call(
      day: day,
      index: index,
      user: _users[index % _users.length],
      host: _hosts[(index * 3) % _hosts.length],
      type: index.isEven ? CallLogType.audio : CallLogType.video,
      initiated: (clamped ~/ 60, clamped % 60, (index * 17) % 60),
      ringSeconds: 10 + index % 20,
      talkSeconds: talkSeconds == null ? null : talkSeconds + index * 11,
      endedBy: endedBy,
      status: status,
    );
  }

  static final CallLog referenceCall = _call(
    day: today.subtract(const Duration(days: 1)),
    index: _todayCount + _olderCount,
    user: 'Arjun Nair',
    host: 'Nandana',
    type: CallLogType.video,
    initiated: (15, 37, 53),
    ringSeconds: 19,
    talkSeconds: 135,
    endedBy: _endedByUser,
    status: CallLogStatus.completed,
    userId: 'ZU10231',
    hostId: 'ZH10290',
    callId: 'CL784520',
    sessionId: 'SES-4b28b44c',
  );

  static final List<CallLog> calls = [
    ..._screenshotCalls,
    for (var i = _screenshotCalls.length; i < _todayCount; i++)
      _generated(today, i),
    referenceCall,
    for (var i = 0; i < _olderCount; i++)
      _generated(today.subtract(Duration(days: 1 + i ~/ 3)), _todayCount + i),
  ];
}
