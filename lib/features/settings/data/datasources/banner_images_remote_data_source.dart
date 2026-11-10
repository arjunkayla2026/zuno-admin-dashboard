import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_upload.dart';

class BannerImagesRemoteDataSource {
  const BannerImagesRemoteDataSource(this._firestore, this._storage);

  static const String _settingsCollection = 'settings';
  static const String _bannerImagesDocument = 'bannerImages';
  static const String _storageFolder = 'bannerImages';

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DocumentReference<Map<String, dynamic>> get _bannerImages =>
      _firestore.collection(_settingsCollection).doc(_bannerImagesDocument);

  Future<Either<Failure, List<BannerImage>>> fetchBanners() async {
    try {
      final snapshot = await _bannerImages.get();
      final banners = [
        for (final MapEntry(:key, :value) in (snapshot.data() ?? {}).entries)
          if (value is Map)
            BannerImage.fromFirestore(key, Map<String, dynamic>.from(value)),
      ]..sort(BannerImage.newestFirst);
      return right(banners);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, BannerImage>> addBanner(BannerUpload upload) async {
    final id = _firestore.collection(_settingsCollection).doc().id;
    final object = _storage.ref(
      '$_storageFolder/${upload.role.name}/$id'
      '${_extension(upload.fileName)}',
    );

    final String imageUrl;
    try {
      await object.putData(
        upload.bytes,
        SettableMetadata(contentType: upload.contentType),
      );
      imageUrl = await object.getDownloadURL();
    } on FirebaseException catch (error) {
      return left(_uploadFailure(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.bannerUploadFailed));
    }

    final banner = BannerImage(
      id: id,
      imageName: upload.fileName,
      imageUrl: imageUrl,
      role: upload.role,
      status: BannerStatus.active,
      createdAt: DateTime.now(),
    );

    try {
      await _bannerImages.set({
        id: banner.toFirestore(),
      }, SetOptions(merge: true));
      return right(banner);
    } on FirebaseException catch (error) {
      await _discard(object);
      return left(FirestoreFailures.write(error.code));
    } catch (_) {
      await _discard(object);
      return left(const DataFailure(AppStrings.recordsSaveFailed));
    }
  }

  Future<Either<Failure, Unit>> deleteBanner(BannerImage banner) async {
    try {
      await _bannerImages.update({
        FieldPath([banner.id]): FieldValue.delete(),
      });
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.write(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsSaveFailed));
    }

    try {
      await _discard(_storage.refFromURL(banner.imageUrl));
    } catch (_) {}
    return right(unit);
  }

  static String _extension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot < 0 ? '' : fileName.substring(dot).toLowerCase();
  }

  static DataFailure _uploadFailure(String code) => DataFailure(switch (code) {
    'unauthorized' || 'unauthenticated' => AppStrings.bannerUploadDenied,
    'retry-limit-exceeded' => AppStrings.recordsNetworkError,
    _ => AppStrings.bannerUploadFailed,
  });

  static Future<void> _discard(Reference object) async {
    try {
      await object.delete();
    } catch (_) {}
  }
}
