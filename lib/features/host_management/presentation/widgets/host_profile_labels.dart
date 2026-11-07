import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';

abstract final class HostProfileLabels {
  static String gender(HostGender gender) => switch (gender) {
    HostGender.female => AppStrings.female,
    HostGender.male => AppStrings.male,
    HostGender.other => AppStrings.otherGender,
  };

  static String language(HostLanguage language) => switch (language) {
    HostLanguage.english => AppStrings.english,
    HostLanguage.malayalam => AppStrings.malayalam,
    HostLanguage.tamil => AppStrings.tamil,
    HostLanguage.hindi => AppStrings.hindi,
    HostLanguage.kannada => AppStrings.kannada,
    HostLanguage.telugu => AppStrings.telugu,
  };

  static String languageList(Iterable<HostLanguage> languages) =>
      languages.map(language).join(', ');
}
