import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';
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
}
