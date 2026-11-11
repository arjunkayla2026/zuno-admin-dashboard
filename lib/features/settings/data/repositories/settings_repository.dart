import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/host_pricing.dart';
import 'package:zuno_admin_dashboard/core/data/admin_account.dart';
import 'package:zuno_admin_dashboard/core/data/admins_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';
import 'package:zuno_admin_dashboard/features/settings/data/datasources/banner_images_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/settings/data/datasources/notifications_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_upload.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/notification_audience_counts.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/notification_request.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/data/models/surge_session.dart';

class SettingsRepository {
  const SettingsRepository(
    this._adminsDataSource,
    this._settingsDataSource,
    this._bannerImagesDataSource,
    this._usersDataSource,
    this._notificationsDataSource,
  );

  static const String _userRole = 'user';
  static const String _hostRole = 'host';

  final AdminsRemoteDataSource _adminsDataSource;
  final SettingsRemoteDataSource _settingsDataSource;
  final BannerImagesRemoteDataSource _bannerImagesDataSource;
  final UsersRemoteDataSource _usersDataSource;
  final NotificationsRemoteDataSource _notificationsDataSource;

  Future<Either<Failure, NotificationSendResult>> sendNotification(
    NotificationRequest request,
  ) => _notificationsDataSource.send(request);

  Future<Either<Failure, NotificationAudienceCounts>>
  fetchNotificationAudience() async {
    final results = await Future.wait([
      _usersDataSource.countNotDeleted(_userRole),
      _usersDataSource.countNotDeleted(_hostRole),
      for (final language in HostLanguage.values)
        _usersDataSource.countNotDeleted(
          _hostRole,
          motherTongue: language.name,
        ),
    ]);
    return Either.sequenceList(results).map(
      (counts) => NotificationAudienceCounts(
        users: counts[0],
        hosts: counts[1],
        hostsByMotherTongue: {
          for (final (index, language) in HostLanguage.values.indexed)
            language: counts[index + 2],
        },
      ),
    );
  }

  Future<Either<Failure, List<BannerImage>>> fetchBanners() =>
      _bannerImagesDataSource.fetchBanners();

  Future<Either<Failure, BannerImage>> addBanner(BannerUpload upload) =>
      _bannerImagesDataSource.addBanner(upload);

  Future<Either<Failure, Unit>> deleteBanner(BannerImage banner) =>
      _bannerImagesDataSource.deleteBanner(banner);

  Future<Either<Failure, bool>> fetchMaintenanceMode() =>
      _settingsDataSource.fetchMaintenanceMode();

  Future<Either<Failure, Unit>> setMaintenanceMode(bool enabled) =>
      _settingsDataSource.setMaintenanceMode(enabled);

  Future<Either<Failure, HostPricing>> fetchHostPricing() =>
      _settingsDataSource.fetchHostPricing();

  Future<Either<Failure, Unit>> saveHostPricing(HostPricing pricing) =>
      _settingsDataSource.saveHostPricing(pricing);

  Future<Either<Failure, List<SurgeSession>>> fetchSurgeSessions() =>
      _settingsDataSource.fetchSurgeSessions();

  Future<Either<Failure, Unit>> saveSurgeSessions(
    List<SurgeSession> sessions,
  ) => _settingsDataSource.saveSurgeSessions(sessions);

  Future<Either<Failure, List<AdminAccount>>> fetchAdmins() async {
    final result = await _adminsDataSource.fetchAdmins();
    return result.map((admins) => [...admins]..sort(AdminAccount.oldestFirst));
  }

  Future<Either<Failure, AdminAccount>> saveAdmin(
    AdminAccount admin, {
    AdminAccount? replacing,
    String? password,
  }) async {
    final normalized = admin.copyWith(
      id: replacing?.id,
      email: AdminAccount.normalizeEmail(replacing?.email ?? admin.email),
      createdAt: replacing?.createdAt ?? DateTime.now(),
    );
    if (replacing != null) {
      if (password != null) {
        final login = await _adminsDataSource.createLogin(
          email: normalized.email,
          password: password,
          keepExisting: false,
        );
        if (login case Left(:final value)) return left(value);
      }
      final result = await _adminsDataSource.updateAdmin(normalized);
      return result.map((_) => normalized);
    }

    final existing = await _adminsDataSource.findByEmail(normalized.email);
    if (existing case Left(:final value)) return left(value);
    if (existing.getOrElse((_) => null) != null) {
      return left(const DataFailure(AppStrings.adminEmailExists));
    }
    if (password != null) {
      final login = await _adminsDataSource.createLogin(
        email: normalized.email,
        password: password,
      );
      if (login case Left(:final value)) return left(value);
    }
    final result = await _adminsDataSource.createAdmin(normalized);
    return result.map((id) => normalized.copyWith(id: id));
  }
}
