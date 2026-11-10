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
    this.banners = const [],
    this.bannersStatus = LoadStatus.loading,
    this.bannersError,
    this.adminsStatus = LoadStatus.loading,
    this.adminsError,
    this.tab = SettingsTab.maintenanceMode,
    this.maintenanceEnabled = false,
    this.maintenanceStatus = LoadStatus.loading,
    this.maintenanceError,
    this.maintenanceSaving = false,
  });

  final List<AdminAccount> admins;
  final LoadStatus adminsStatus;
  final String? adminsError;
  final int activeUsers;
  final Map<HostLanguage, int> activeHostsByLanguage;
  final List<BannerImage> banners;
  final LoadStatus bannersStatus;
  final String? bannersError;
  final SettingsTab tab;
  final bool maintenanceEnabled;
  final LoadStatus maintenanceStatus;
  final String? maintenanceError;
  final bool maintenanceSaving;

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
    LoadStatus? bannersStatus,
    String? bannersError,
    SettingsTab? tab,
    bool? maintenanceEnabled,
    LoadStatus? maintenanceStatus,
    String? maintenanceError,
    bool? maintenanceSaving,
  }) {
    return SettingsState(
      admins: admins ?? this.admins,
      adminsStatus: adminsStatus ?? this.adminsStatus,
      adminsError: adminsError ?? this.adminsError,
      activeUsers: activeUsers,
      activeHostsByLanguage: activeHostsByLanguage,
      banners: banners ?? this.banners,
      bannersStatus: bannersStatus ?? this.bannersStatus,
      bannersError: bannersError ?? this.bannersError,
      tab: tab ?? this.tab,
      maintenanceEnabled: maintenanceEnabled ?? this.maintenanceEnabled,
      maintenanceStatus: maintenanceStatus ?? this.maintenanceStatus,
      maintenanceError: maintenanceError ?? this.maintenanceError,
      maintenanceSaving: maintenanceSaving ?? this.maintenanceSaving,
    );
  }
}
