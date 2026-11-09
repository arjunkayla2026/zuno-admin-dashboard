import 'package:zuno_admin_dashboard/core/data/admin_account.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';

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
    required this.banners,
    this.adminsStatus = LoadStatus.loading,
    this.adminsError,
    this.tab = SettingsTab.maintenanceMode,
    this.maintenanceEnabled = false,
  });

  final List<AdminAccount> admins;
  final LoadStatus adminsStatus;
  final String? adminsError;
  final int activeUsers;
  final Map<HostLanguage, int> activeHostsByLanguage;
  final List<BannerImage> banners;
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
    LoadStatus? adminsStatus,
    String? adminsError,
    List<BannerImage>? banners,
    SettingsTab? tab,
    bool? maintenanceEnabled,
  }) {
    return SettingsState(
      admins: admins ?? this.admins,
      adminsStatus: adminsStatus ?? this.adminsStatus,
      adminsError: adminsError ?? this.adminsError,
      activeUsers: activeUsers,
      activeHostsByLanguage: activeHostsByLanguage,
      banners: banners ?? this.banners,
      tab: tab ?? this.tab,
      maintenanceEnabled: maintenanceEnabled ?? this.maintenanceEnabled,
    );
  }
}
