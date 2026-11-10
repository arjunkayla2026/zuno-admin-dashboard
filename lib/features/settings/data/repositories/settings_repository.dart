import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/admin_account.dart';
import 'package:zuno_admin_dashboard/core/data/admins_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/settings/data/datasources/banner_images_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_upload.dart';

class SettingsRepository {
  const SettingsRepository(
    this._adminsDataSource,
    this._settingsDataSource,
    this._bannerImagesDataSource,
  );

  final AdminsRemoteDataSource _adminsDataSource;
  final SettingsRemoteDataSource _settingsDataSource;
  final BannerImagesRemoteDataSource _bannerImagesDataSource;

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
    return result.map((_) => normalized);
  }
}
