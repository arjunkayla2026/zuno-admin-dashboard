class GeneralSettings {
  const GeneralSettings({
    required this.maintenanceEnabled,
    this.minimumPayoutAmount,
  });

  final bool maintenanceEnabled;
  final double? minimumPayoutAmount;
}
