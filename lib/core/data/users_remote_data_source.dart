import 'dart:math';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/approval_audit.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/search_keywords.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';

class UsersRemoteDataSource {
  const UsersRemoteDataSource(this._firestore, this._auth);

  static const String _collection = 'users';
  static const int _maxIdsPerQuery = 30;
  static const String _roleField = 'role';
  static const String _hostStatusField = 'hostDetails.hostStatus';
  static const String _updatedAtField = 'updatedAt';
  static const String _createdAtField = 'createdAt';
  static const String _blockedField = 'isAccountBlocked';
  static const String _deletedField = 'isAccountDeleted';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<Either<Failure, RecordPage<UserRecord>>> fetchUsersPage(
    String role,
    RecordPageQuery query, {
    required int pageSize,
    bool onlyBlocked = false,
    bool onlyDeleted = false,
    String? deletedBy,
  }) {
    var base = _firestore
        .collection(_collection)
        .where(_roleField, isEqualTo: role);
    if (onlyBlocked) base = base.where(_blockedField, isEqualTo: true);
    if (onlyDeleted) base = base.where(_deletedField, isEqualTo: true);
    if (deletedBy != null) {
      base = base.where(UserRecord.deletedByField, isEqualTo: deletedBy);
    }
    return RecordPages.fetch(
      base,
      query,
      UserRecord.fromDocument,
      sortField: _createdAtField,
      pageSize: pageSize,
    );
  }

  Query<Map<String, dynamic>> get _hostApplicants => _firestore
      .collection(_collection)
      .where(_hostStatusField, isEqualTo: UserRecord.documentSubmitted);

  Query<Map<String, dynamic>> get _profilePhotoRequests => _firestore
      .collection(_collection)
      .where(UserRecord.isAvatarField, isEqualTo: false)
      .where(
        UserRecord.avatarStatusField,
        isEqualTo: UserRecord.avatarSubmitted,
      );

  Future<Either<Failure, RecordPage<UserRecord>>> fetchHostApplicants(
    RecordPageQuery query,
  ) => RecordPages.fetch(_hostApplicants, query, UserRecord.fromDocument);

  Future<Either<Failure, int>> countHostApplicants(RecordPageQuery query) =>
      RecordPages.count(_hostApplicants, query);

  Future<Either<Failure, RecordPage<UserRecord>>> fetchProfilePhotoRequests(
    RecordPageQuery query,
  ) => RecordPages.fetch(_profilePhotoRequests, query, UserRecord.fromDocument);

  Future<Either<Failure, int>> countProfilePhotoRequests(
    RecordPageQuery query,
  ) => RecordPages.count(_profilePhotoRequests, query);

  // Future<Either<Failure, List<UserRecord>>> fetchByIds(List<String> ids) async {
  //   final results = await Future.wait([
  //     for (var start = 0; start < ids.length; start += _maxIdsPerQuery)
  //       _fetch(
  //         _firestore
  //             .collection(_collection)
  //             .where(
  //               FieldPath.documentId,
  //               whereIn: ids.sublist(
  //                 start,
  //                 min(start + _maxIdsPerQuery, ids.length),
  //               ),
  //             ),
  //       ),
  //   ]);
  //   return Either.sequenceList(results)
  //       .map((groups) => groups.expand((group) => group).toList());
  // }

  Future<Either<Failure, List<UserRecord>>> fetchByIds(
    Iterable<String> ids,
  ) async {
    final unique = ids.where((id) => id.isNotEmpty).toSet().toList();
    if (unique.isEmpty) return right(const []);
    try {
      final snapshots = await Future.wait([
        for (var start = 0; start < unique.length; start += _maxIdsPerQuery)
          _firestore
              .collection(_collection)
              .where(
                FieldPath.documentId,
                whereIn: unique.sublist(
                  start,
                  math.min(start + _maxIdsPerQuery, unique.length),
                ),
              )
              .get(),
      ]);
      return right([
        for (final snapshot in snapshots)
          for (final document in snapshot.docs)
            UserRecord.fromDocument(document.id, document.data()),
      ]);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, Unit>> updateRecord(
    String id,
    Map<String, Object?> fields,
  ) async {
    if (fields.isEmpty) return right(unit);
    try {
      if (SearchKeywords.touchesSearchableField(fields)) {
        await _updateWithKeywords(id, fields);
      } else {
        await _firestore.collection(_collection).doc(id).update({
          ...fields,
          _updatedAtField: FieldValue.serverTimestamp(),
        });
      }
      return right(unit);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.write(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsSaveFailed));
    }
  }

  Future<void> _updateWithKeywords(String id, Map<String, Object?> fields) {
    final userReference = _firestore.collection(_collection).doc(id);
    final bankReference = _firestore
        .collection(SearchKeywords.bankAccountsCollection)
        .doc(id);

    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userReference);
      final bankSnapshot = await transaction.get(bankReference);
      final userData = userSnapshot.data();
      if (userData == null) {
        throw FirebaseException(plugin: 'cloud_firestore', code: 'not-found');
      }

      final merged = SearchKeywords.withUpdates(userData, fields);
      transaction.update(userReference, {
        ...fields,
        SearchKeywords.field: SearchKeywords.forUser(merged),
        _updatedAtField: FieldValue.serverTimestamp(),
      });
      if (bankSnapshot.data() case final bankData?) {
        transaction.update(bankReference, {
          SearchKeywords.field: SearchKeywords.forBankAccount(bankData, merged),
        });
      }
    });
  }

  Future<Either<Failure, Unit>> reviewHostDocument(
    String id, {
    required String document,
    required String status,
  }) => _transact(
    id,
    (data, _) =>
        UserRecord.hostDocumentReview(data, document: document, status: status),
    refusedMessage: AppStrings.documentAlreadyReviewed,
    audit: (adminUid) => ApprovalAudit.entry(
      userId: id,
      adminUid: adminUid,
      type: ApprovalAudit.hostDocument,
      status: status,
      previousStatus: UserRecord.documentSubmitted,
      document: document,
    ),
  );

  Future<Either<Failure, Unit>> decideHostRequest(
    String id, {
    required bool approved,
  }) => _transact(
    id,
    (data, adminUid) => UserRecord.hostRequestDecision(
      data,
      approved: approved,
      adminUid: adminUid,
    ),
    refusedMessage: AppStrings.hostRequestNotReady,
    audit: (adminUid) => ApprovalAudit.entry(
      userId: id,
      adminUid: adminUid,
      type: ApprovalAudit.hostRequest,
      status: approved
          ? UserRecord.documentApproved
          : UserRecord.documentRejected,
      previousStatus: UserRecord.documentSubmitted,
    ),
  );

  Future<Either<Failure, Unit>> decideProfilePhoto(
    String id, {
    required bool approved,
    required String reviewedUrl,
  }) => _transact(
    id,
    (data, adminUid) => UserRecord.profilePhotoDecision(
      data,
      approved: approved,
      reviewedUrl: reviewedUrl,
      adminUid: adminUid,
    ),
    refusedMessage: AppStrings.profilePhotoChanged,
    audit: (adminUid) => ApprovalAudit.entry(
      userId: id,
      adminUid: adminUid,
      type: ApprovalAudit.profilePhoto,
      status: approved
          ? UserRecord.documentApproved
          : UserRecord.documentRejected,
      previousStatus: UserRecord.avatarSubmitted,
      imageUrl: reviewedUrl,
    ),
  );

  Future<Either<Failure, Unit>> _transact(
    String id,
    Map<String, Object?>? Function(Map<String, dynamic> data, String adminUid)
    buildUpdate, {
    required String refusedMessage,
    required Map<String, Object?> Function(String adminUid) audit,
    String auditCollection = ApprovalAudit.collection,
  }) async {
    final adminUid = _auth.currentUser?.uid;
    if (adminUid == null) {
      return left(const DataFailure(AppStrings.recordsWriteDenied));
    }

    final reference = _firestore.collection(_collection).doc(id);
    Failure? refused;
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(reference);
        final data = snapshot.data();
        final update = data == null ? null : buildUpdate(data, adminUid);
        if (update == null) {
          refused = DataFailure(
            data == null ? AppStrings.recordNotFound : refusedMessage,
          );
          return;
        }
        transaction.update(reference, {
          ...update,
          _updatedAtField: FieldValue.serverTimestamp(),
        });
        transaction.set(
          _firestore.collection(auditCollection).doc(),
          audit(adminUid),
        );
      });
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.write(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsSaveFailed));
    }
    final failure = refused;
    return failure == null ? right(unit) : left(failure);
  }

  Future<Either<Failure, Unit>> adjustWallet(
    String id, {
    required bool isCredit,
    required int amount,
    required String ledgerCollection,
    required Map<String, Object?> Function(String adminUid) ledgerEntry,
  }) => _transact(
    id,
    (data, _) =>
        UserRecord.walletAdjustment(data, isCredit: isCredit, amount: amount),
    refusedMessage: AppStrings.walletBalanceTooLow,
    audit: ledgerEntry,
    auditCollection: ledgerCollection,
  );

  Future<Either<Failure, Unit>> setBlocked(
    String id, {
    required bool blocked,
  }) => updateRecord(id, {_blockedField: blocked});

  Future<Either<Failure, Unit>> markDeletedByAdmin(String id) => updateRecord(
    id,
    {_deletedField: true, UserRecord.deletedByField: UserRecord.deletedByAdmin},
  );
}
