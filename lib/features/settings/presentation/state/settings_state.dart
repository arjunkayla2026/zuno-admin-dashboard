import 'package:zuno_admin_dashboard/core/data/admin_account.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/notification_audience_counts.dart';

enum SettingsTab {
  maintenanceMode,
  adminManagement,
  notificationManagement,
  bannerImageManagement,
}

class SettingsState {
  const SettingsState({
    required this.admins,
    this.audience,
    this.audienceStatus = LoadStatus.loading,
    this.audienceError,
    this.notificationSending = false,
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
    this.minimumPayout,
    this.minimumPayoutSaving = false,
  });

  final List<AdminAccount> admins;
  final LoadStatus adminsStatus;
  final String? adminsError;
  final NotificationAudienceCounts? audience;
  final LoadStatus audienceStatus;
  final String? audienceError;
  final bool notificationSending;
  final List<BannerImage> banners;
  final LoadStatus bannersStatus;
  final String? bannersError;
  final SettingsTab tab;
  final bool maintenanceEnabled;
  final LoadStatus maintenanceStatus;
  final String? maintenanceError;
  final bool maintenanceSaving;
  final double? minimumPayout;
  final bool minimumPayoutSaving;

  SettingsState copyWith({
    List<AdminAccount>? admins,
    LoadStatus? adminsStatus,
    String? adminsError,
    NotificationAudienceCounts? audience,
    LoadStatus? audienceStatus,
    String? audienceError,
    bool? notificationSending,
    List<BannerImage>? banners,
    LoadStatus? bannersStatus,
    String? bannersError,
    SettingsTab? tab,
    bool? maintenanceEnabled,
    LoadStatus? maintenanceStatus,
    String? maintenanceError,
    bool? maintenanceSaving,
    double? minimumPayout,
    bool? minimumPayoutSaving,
  }) {
    return SettingsState(
      admins: admins ?? this.admins,
      adminsStatus: adminsStatus ?? this.adminsStatus,
      adminsError: adminsError ?? this.adminsError,
      audience: audience ?? this.audience,
      audienceStatus: audienceStatus ?? this.audienceStatus,
      audienceError: audienceError ?? this.audienceError,
      notificationSending: notificationSending ?? this.notificationSending,
      banners: banners ?? this.banners,
      bannersStatus: bannersStatus ?? this.bannersStatus,
      bannersError: bannersError ?? this.bannersError,
      tab: tab ?? this.tab,
      maintenanceEnabled: maintenanceEnabled ?? this.maintenanceEnabled,
      maintenanceStatus: maintenanceStatus ?? this.maintenanceStatus,
      maintenanceError: maintenanceError ?? this.maintenanceError,
      maintenanceSaving: maintenanceSaving ?? this.maintenanceSaving,
      minimumPayout: minimumPayout ?? this.minimumPayout,
      minimumPayoutSaving: minimumPayoutSaving ?? this.minimumPayoutSaving,
    );
  }
}
