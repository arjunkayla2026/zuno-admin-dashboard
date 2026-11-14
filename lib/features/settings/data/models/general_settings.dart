class GeneralSettings {
  const GeneralSettings({
    required this.maintenanceEnabled,
    this.minimumPayoutAmount,
    this.allowedVersions = const [],
  });

  static const String allowedVersionsField = 'allowedVersions';

  final bool maintenanceEnabled;
  final double? minimumPayoutAmount;
  final List<String> allowedVersions;

  static List<String> readAllowedVersions(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is String && item.trim().isNotEmpty) item.trim(),
    ];
  }
}
