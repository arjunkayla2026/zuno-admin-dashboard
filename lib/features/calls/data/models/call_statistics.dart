class CallStatistics {
  const CallStatistics({
    required this.incoming,
    required this.answered,
    required this.rejected,
    required this.missed,
    this.talkSeconds,
  });

  final int incoming;
  final int answered;
  final int rejected;
  final int missed;

  /// Null when the duration sum could not be read.
  final int? talkSeconds;

  int? get talkMinutes {
    final seconds = talkSeconds;
    return seconds == null ? null : seconds ~/ Duration.secondsPerMinute;
  }
}
