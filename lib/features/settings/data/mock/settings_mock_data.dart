import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/admin_account.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';

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

  static final List<BannerImage> banners = [
    BannerImage(
      fileName: 'bonus-199.png',
      headline: 'Get +50 bonus coins',
      subheading: 'On the ₹199 recharge pack',
      actionLabel: 'Recharge',
      artwork: BannerArtwork.navy,
      addedOn: DateTime(2026, 11, 1),
    ),
    BannerImage(
      fileName: 'languages.png',
      headline: 'Talk in your language',
      subheading: 'Malayalam, Tamil, Hindi and more',
      actionLabel: 'Explore',
      artwork: BannerArtwork.brown,
      addedOn: DateTime(2026, 10, 26),
    ),
    BannerImage(
      fileName: 'mega-pack.png',
      headline: 'Mega pack is here',
      subheading: '2,500 coins with +400 bonus',
      actionLabel: 'Recharge',
      artwork: BannerArtwork.teal,
      addedOn: DateTime(2026, 10, 14),
    ),
  ];

  static final BannerImage sampleBanner = BannerImage(
    fileName: 'new-banner.png',
    headline: 'New banner',
    subheading: 'Sample artwork for the chosen image',
    actionLabel: 'Open',
    artwork: BannerArtwork.navy,
    addedOn: DateTime(2026, 11, 4),
  );

  static const List<AdminAccount> admins = [
    AdminAccount(
      name: 'Rakesh Menon',
      email: 'rakesh@yellowcalling.app',
      role: AdminRole.superAdmin,
      phone: '+91 98470 11234',
    ),
    AdminAccount(
      name: 'Divya Suresh',
      email: 'divya@yellowcalling.app',
      role: AdminRole.financeAdmin,
      phone: '+91 94461 55320',
      modules: [
        AdminNavItem.dashboard,
        AdminNavItem.recharge,
        AdminNavItem.payment,
        AdminNavItem.packages,
      ],
    ),
    AdminAccount(
      name: 'Joel Mathew',
      email: 'joel@yellowcalling.app',
      role: AdminRole.supportAdmin,
      phone: '+91 90372 88101',
      modules: [
        AdminNavItem.userManagement,
        AdminNavItem.hostManagement,
        AdminNavItem.calls,
        AdminNavItem.reports,
      ],
    ),
    AdminAccount(
      name: 'Nisha Ramesh',
      email: 'nisha@yellowcalling.app',
      role: AdminRole.moderator,
      phone: '+91 97782 40917',
      modules: [AdminNavItem.approval, AdminNavItem.reports],
    ),
  ];
}
