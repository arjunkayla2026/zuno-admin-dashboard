import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';

abstract final class BannerLabels {
  static String screen(BannerScreen screen) => switch (screen) {
    BannerScreen.home => AppStrings.homeScreen,
    BannerScreen.recharge => AppStrings.rechargeScreen,
  };

  static String option(BannerScreen screen) => switch (screen) {
    BannerScreen.home => AppStrings.homeBanner,
    BannerScreen.recharge => AppStrings.rechargeBanner,
  };

  static String audience(BannerAudience audience) => switch (audience) {
    BannerAudience.user => AppStrings.userAudience,
    BannerAudience.host => AppStrings.hostAudience,
  };
}
