import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';

class SettingsRemoteDataSource {
  const SettingsRemoteDataSource(this._firestore);

  static const String _collection = 'settings';
  static const String _appDocument = 'app';
  static const String maintenanceModeField = 'isMaintenanceMode';
  static const String updatedAtField = 'updatedAt';

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _app =>
      _firestore.collection(_collection).doc(_appDocument);

  Future<Either<Failure, bool>> fetchMaintenanceMode() async {
    try {
      final snapshot = await _app.get();
      return right(snapshot.data()?[maintenanceModeField] == true);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, Unit>> setMaintenanceMode(bool enabled) async {
    try {
      await _app.set({
        maintenanceModeField: enabled,
        updatedAtField: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return right(unit);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.write(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsSaveFailed));
    }
  }
}
