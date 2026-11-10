import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';

class NotificationAudienceCounts {
  const NotificationAudienceCounts({
    required this.users,
    required this.hosts,
    required this.hostsByMotherTongue,
  });

  final int users;
  final int hosts;
  final Map<HostLanguage, int> hostsByMotherTongue;

  int hostsFor(Set<HostLanguage> motherTongues) => motherTongues.isEmpty
      ? hosts
      : motherTongues.fold(
          0,
          (sum, language) => sum + (hostsByMotherTongue[language] ?? 0),
        );
}
