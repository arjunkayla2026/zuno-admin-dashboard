enum CallLogType { audio, video }

enum CallLogStatus {
  completed,
  busy,
  rejected,
  notAnswered,
  lowBalance,
  missed,
}

class CallLog {
  const CallLog({
    required this.callId,
    required this.sessionId,
    required this.userName,
    required this.userId,
    required this.userPhone,
    required this.hostName,
    required this.hostId,
    required this.type,
    required this.initiatedAt,
    required this.endedAt,
    required this.endedBy,
    required this.status,
    this.startedAt,
  });

  static const int _secondsPerMinute = Duration.secondsPerMinute;
  static const int _coinsPerRupee = 2;

  final String callId;
  final String sessionId;
  final String userName;
  final String userId;
  final String userPhone;
  final String hostName;
  final String hostId;
  final CallLogType type;
  final DateTime initiatedAt;
  final DateTime? startedAt;
  final DateTime endedAt;
  final String endedBy;
  final CallLogStatus status;

  int? get durationSeconds =>
      startedAt == null ? null : endedAt.difference(startedAt!).inSeconds;

  int get coinsPerSecond => switch (type) {
    CallLogType.audio => 1,
    CallLogType.video => 2,
  };

  int get hostRatePerMinute => switch (type) {
    CallLogType.audio => 12,
    CallLogType.video => 24,
  };

  int get adminRatePerMinute =>
      coinsPerSecond * _secondsPerMinute ~/ _coinsPerRupee - hostRatePerMinute;

  int get spendCoins => (durationSeconds ?? 0) * coinsPerSecond;

  double get spendRupees => spendCoins / _coinsPerRupee;

  double get hostEarnings =>
      (durationSeconds ?? 0) * hostRatePerMinute / _secondsPerMinute;

  double get adminRevenue => spendRupees - hostEarnings;
}
