import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';

abstract final class SettingsMockData {
  static const int activeUsers = 8240;

  static const Map<HostLanguage, int> activeHostsByLanguage = {
    HostLanguage.english: 120,
    HostLanguage.malayalam: 446,
    HostLanguage.tamil: 280,
    HostLanguage.hindi: 110,
    HostLanguage.kannada: 80,
    HostLanguage.telugu: 90,
  };
}
