enum CallType { audio, video }

enum CallStatus { completed, rejected, notAnswered, lowBalance }

class CallRecord {
  const CallRecord({
    required this.date,
    required this.hostName,
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
  final String hostName;
  final CallType type;
  final String initiatedTime;
  final String? startTime;
  final String endTime;
  final String endedBy;
  final CallStatus status;
  final String? duration;
  final String spendCoins;
  final String totalSpend;
  final String hostRevenue;
}
