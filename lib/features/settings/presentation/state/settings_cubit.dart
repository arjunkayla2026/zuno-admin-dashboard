import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/features/settings/data/mock/settings_mock_data.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/admin_account.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
    : super(
        SettingsState(
          admins: SettingsMockData.admins,
          activeUsers: SettingsMockData.activeUsers,
          activeHostsByLanguage: SettingsMockData.activeHostsByLanguage,
          banners: SettingsMockData.banners,
        ),
      );

  void selectTab(SettingsTab tab) => emit(state.copyWith(tab: tab));

  void setMaintenance(bool enabled) =>
      emit(state.copyWith(maintenanceEnabled: enabled));

  void saveAdmin(AdminAccount admin, {AdminAccount? replacing}) {
    final admins = replacing == null
        ? [...state.admins, admin]
        : [
            for (final current in state.admins)
              identical(current, replacing) ? admin : current,
          ];
    emit(state.copyWith(admins: admins));
  }

  void addBanner(BannerAudience audience) {
    final banner = SettingsMockData.sampleBanner.copyWith(audience: audience);
    emit(state.copyWith(banners: [...state.banners, banner]));
  }

  void deleteBannerAt(int index) {
    emit(state.copyWith(banners: [...state.banners]..removeAt(index)));
  }
}
