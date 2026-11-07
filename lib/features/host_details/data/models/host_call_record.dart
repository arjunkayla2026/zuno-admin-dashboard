enum HostCallType { audio, video }

enum HostCallStatus { completed, lowBalance, busy, rejected }

class HostCallRecord {
  const HostCallRecord({
    required this.date,
    required this.userName,
    required this.userId,
    required this.type,
    required this.initiatedTime,
    required this.endTime,
    required this.endedBy,
    required this.status,
    required this.spendCoins,
    required this.totalSpend,
    required this.hostRevenue,
    this.startTime,
    this.duration,
  });

  final DateTime date;
  final String userName;
  final String userId;
  final HostCallType type;
  final String initiatedTime;
  final String? startTime;
  final String endTime;
  final String endedBy;
  final String? duration;
  final HostCallStatus status;
  final String spendCoins;
  final String totalSpend;
  final String hostRevenue;
}
