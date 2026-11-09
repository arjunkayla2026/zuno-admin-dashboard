import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';

class PackagesRemoteDataSource {
  const PackagesRemoteDataSource(this._firestore);

  static const String _collection = 'packages';

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _packages =>
      _firestore.collection(_collection);

  Future<Either<Failure, List<PackagePlan>>> fetchPackages() async {
    try {
      final snapshot = await _packages.get();
      return right([
        for (final document in snapshot.docs)
          PackagePlan.fromDocument(document.id, document.data()),
      ]);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, String>> createPackage(
    Map<String, Object?> fields,
  ) async {
    try {
      final reference = await _packages.add({
        ...fields,
        PackagePlan.createdAtField: FieldValue.serverTimestamp(),
        PackagePlan.updatedAtField: FieldValue.serverTimestamp(),
      });
      return right(reference.id);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.write(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsSaveFailed));
    }
  }

  Future<Either<Failure, Unit>> updatePackage(
    String id,
    Map<String, Object?> fields,
  ) async {
    try {
      await _packages.doc(id).update({
        ...fields,
        PackagePlan.updatedAtField: FieldValue.serverTimestamp(),
      });
      return right(unit);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.write(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsSaveFailed));
    }
  }
}
