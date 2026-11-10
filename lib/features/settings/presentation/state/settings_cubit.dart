import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/admin_account.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_upload.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/notification_request.dart';
import 'package:zuno_admin_dashboard/features/settings/data/repositories/settings_repository.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsState(admins: []));

  final SettingsRepository _repository;

  void selectTab(SettingsTab tab) => emit(state.copyWith(tab: tab));

  Future<void> loadNotificationAudience() async {
    emit(state.copyWith(audienceStatus: LoadStatus.loading));
    final result = await _repository.fetchNotificationAudience();
    if (isClosed) return;

    result.match(
      (failure) => emit(
        state.copyWith(
          audienceStatus: LoadStatus.failure,
          audienceError: failure.message,
        ),
      ),
      (audience) => emit(
        state.copyWith(audienceStatus: LoadStatus.loaded, audience: audience),
      ),
    );
  }

  Future<Either<Failure, NotificationSendResult>> sendNotification(
    NotificationRequest request,
  ) async {
    emit(state.copyWith(notificationSending: true));
    final result = await _repository.sendNotification(request);
    if (!isClosed) emit(state.copyWith(notificationSending: false));
    return result;
  }

  Future<void> loadMaintenance() async {
    emit(state.copyWith(maintenanceStatus: LoadStatus.loading));
    final result = await _repository.fetchMaintenanceMode();
    if (isClosed) return;

    result.match(
      (failure) => emit(
        state.copyWith(
          maintenanceStatus: LoadStatus.failure,
          maintenanceError: failure.message,
        ),
      ),
      (enabled) => emit(
        state.copyWith(
          maintenanceStatus: LoadStatus.loaded,
          maintenanceEnabled: enabled,
        ),
      ),
    );
  }

  Future<String?> setMaintenance(bool enabled) async {
    emit(state.copyWith(maintenanceSaving: true));
    final result = await _repository.setMaintenanceMode(enabled);
    if (isClosed) return null;

    return result.match(
      (failure) {
        emit(state.copyWith(maintenanceSaving: false));
        return failure.message;
      },
      (_) {
        emit(
          state.copyWith(maintenanceSaving: false, maintenanceEnabled: enabled),
        );
        return null;
      },
    );
  }

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

  Future<void> loadBanners() async {
    emit(state.copyWith(bannersStatus: LoadStatus.loading));
    final result = await _repository.fetchBanners();
    if (isClosed) return;

    result.match(
      (failure) => emit(
        state.copyWith(
          bannersStatus: LoadStatus.failure,
          bannersError: failure.message,
        ),
      ),
      (banners) => emit(
        state.copyWith(bannersStatus: LoadStatus.loaded, banners: banners),
      ),
    );
  }

  Future<String?> addBanner(BannerUpload upload) async {
    final result = await _repository.addBanner(upload);
    return result.match((failure) => failure.message, (banner) {
      if (!isClosed) emit(state.copyWith(banners: [banner, ...state.banners]));
      return null;
    });
  }

  Future<String?> deleteBanner(BannerImage banner) async {
    final result = await _repository.deleteBanner(banner);
    return result.match((failure) => failure.message, (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            banners: [
              for (final item in state.banners)
                if (item.id != banner.id) item,
            ],
          ),
        );
      }
      return null;
    });
  }
}
