class SurgeSession {
  const SurgeSession({
    required this.id,
    required this.startMinutes,
    required this.endMinutes,
    required this.percent,
    required this.enabled,
  });

  final int id;
  final int startMinutes;
  final int endMinutes;
  final int percent;
  final bool enabled;

  SurgeSession copyWith({
    int? id,
    int? startMinutes,
    int? endMinutes,
    int? percent,
    bool? enabled,
  }) {
    return SurgeSession(
      id: id ?? this.id,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      percent: percent ?? this.percent,
      enabled: enabled ?? this.enabled,
    );
  }
}
