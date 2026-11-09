import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/data/admin_account.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/settings/data/mock/settings_mock_data.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';
import 'package:zuno_admin_dashboard/features/settings/data/repositories/settings_repository.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository)
    : super(
        SettingsState(
          admins: const [],
          activeUsers: SettingsMockData.activeUsers,
          activeHostsByLanguage: SettingsMockData.activeHostsByLanguage,
          banners: SettingsMockData.banners,
        ),
      );

  final SettingsRepository _repository;

  void selectTab(SettingsTab tab) => emit(state.copyWith(tab: tab));

  void setMaintenance(bool enabled) =>
      emit(state.copyWith(maintenanceEnabled: enabled));

  Future<void> loadAdmins() async {
    emit(state.copyWith(adminsStatus: LoadStatus.loading));
    final result = await _repository.fetchAdmins();
    if (isClosed) return;

    result.match(
      (failure) => emit(
        state.copyWith(
          adminsStatus: LoadStatus.failure,
          adminsError: failure.message,
        ),
      ),
      (admins) =>
          emit(state.copyWith(adminsStatus: LoadStatus.loaded, admins: admins)),
    );
  }

  Future<String?> saveAdmin(
    AdminAccount admin, {
    AdminAccount? replacing,
    String? password,
  }) async {
    final result = await _repository.saveAdmin(
      admin,
      replacing: replacing,
      password: password,
    );
    return result.match((failure) => failure.message, (saved) {
      if (!isClosed) emit(state.copyWith(admins: _withAdmin(saved)));
      return null;
    });
  }

  List<AdminAccount> _withAdmin(AdminAccount saved) {
    final exists = state.admins.any((admin) => admin.email == saved.email);
    return [
      for (final admin in state.admins)
        admin.email == saved.email ? saved : admin,
      if (!exists) saved,
    ];
  }

  void addBanner(BannerAudience audience) {
    final banner = SettingsMockData.sampleBanner.copyWith(audience: audience);
    emit(state.copyWith(banners: [...state.banners, banner]));
  }

  void deleteBannerAt(int index) {
    emit(state.copyWith(banners: [...state.banners]..removeAt(index)));
  }
}
