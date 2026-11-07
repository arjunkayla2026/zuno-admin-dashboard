import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/admin_account.dart';

enum SettingsTab {
  maintenanceMode,
  adminManagement,
  notificationManagement,
  bannerImageManagement,
}

class SettingsState {
  const SettingsState({
    required this.admins,
    required this.activeUsers,
    required this.activeHostsByLanguage,
    this.tab = SettingsTab.maintenanceMode,
    this.maintenanceEnabled = false,
  });

  final List<AdminAccount> admins;
  final int activeUsers;
  final Map<HostLanguage, int> activeHostsByLanguage;
  final SettingsTab tab;
  final bool maintenanceEnabled;

  int activeHostsFor(Set<HostLanguage> languages) {
    final counts = languages.isEmpty
        ? activeHostsByLanguage.values
        : languages.map((language) => activeHostsByLanguage[language] ?? 0);
    return counts.fold(0, (sum, count) => sum + count);
  }

  SettingsState copyWith({
    List<AdminAccount>? admins,
    SettingsTab? tab,
    bool? maintenanceEnabled,
  }) {
    return SettingsState(
      admins: admins ?? this.admins,
      activeUsers: activeUsers,
      activeHostsByLanguage: activeHostsByLanguage,
      tab: tab ?? this.tab,
      maintenanceEnabled: maintenanceEnabled ?? this.maintenanceEnabled,
    );
  }
}
