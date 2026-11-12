import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/data/host_pricing.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/data/models/surge_session.dart';

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

  Future<Either<Failure, HostPricing>> fetchHostPricing() async {
    try {
      final snapshot = await _app.get();
      return right(HostPricing.fromMap(snapshot.data()?[HostPricing.field]));
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, Unit>> saveHostPricing(HostPricing pricing) async {
    try {
      await _app.set({
        HostPricing.field: {
          for (final channel in PricingChannel.values)
            channel.key: {
              ...pricing
                  .of(channel)
                  .toMap(includeHostAmount: channel.hasHostAmount),
              if (!channel.hasHostAmount)
                ChannelPricing.hostAmountField: FieldValue.delete(),
            },
        },
        updatedAtField: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return right(unit);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.write(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsSaveFailed));
    }
  }

  Future<Either<Failure, List<SurgeSession>>> fetchSurgeSessions() async {
    try {
      final snapshot = await _app.get();
      final pricing = snapshot.data()?[HostPricing.field];
      return right(
        SurgeSession.listFrom(
          pricing is Map ? pricing[SurgeSession.listField] : null,
        ),
      );
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, Unit>> saveSurgeSessions(
    List<SurgeSession> sessions,
  ) async {
    try {
      await _app.set({
        HostPricing.field: {
          SurgeSession.listField: [
            for (final session in sessions) session.toMap(),
          ],
        },
        updatedAtField: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return right(unit);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.write(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsSaveFailed));
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
