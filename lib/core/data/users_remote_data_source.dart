import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/approval_audit.dart';
import 'package:zuno_admin_dashboard/core/data/data_revision.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/search_keywords.dart';
import 'package:zuno_admin_dashboard/core/data/user_account_totals.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/data/user_search.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';

class UsersRemoteDataSource {
  const UsersRemoteDataSource(this._firestore, this._auth, {this._revision});

  static const String userRole = 'user';
  static const String hostRole = 'host';
  static const String _collection = 'users';
  static const String _bonusField =
      '${UserRecord.walletSourcesField}.${UserRecord.bonusField}';
  static const int _maxIdsPerQuery = 30;
  static const String _roleField = 'role';
  static const String _hostStatusField = 'hostDetails.hostStatus';
  static const String _updatedAtField = 'updatedAt';
  static const String _createdAtField = 'createdAt';
  static const String _blockedField = 'isAccountBlocked';
  static const String _deletedField = 'isAccountDeleted';
  static const String _motherTongueField = 'hostDetails.motherTongue';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final DataRevision? _revision;

  Future<(int total, int deleted)> _roleCounts(
    String role, {
    String? motherTongue,
  }) async {
    var base = _firestore
        .collection(_collection)
        .where(_roleField, isEqualTo: role);
    if (motherTongue != null) {
      base = base.where(_motherTongueField, isEqualTo: motherTongue);
    }
    final counts = await Future.wait([
      base.count().get(),
      base.where(_deletedField, isEqualTo: true).count().get(),
    ]);
    return (counts[0].count ?? 0, counts[1].count ?? 0);
  }

  Future<Either<Failure, int>> countNotDeleted(
    String role, {
    String? motherTongue,
  }) async {
    try {
      final (total, deleted) = await _roleCounts(
        role,
        motherTongue: motherTongue,
      );
      return right(total - deleted);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<Either<Failure, UserAccountTotals>> fetchAccountTotals({
    DateTime? from,
    DateTime? until,
  }) async {
    try {
      return right(
        from != null && until != null
            ? await _accountTotalsBetween(from, until)
            : await _allTimeAccountTotals(),
      );
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Future<UserAccountTotals> _accountTotalsBetween(
    DateTime from,
    DateTime until,
  ) async {
    final users = _firestore.collection(_collection);
    Query<Map<String, dynamic>> between(
      Query<Map<String, dynamic>> query,
      String field,
    ) => query
        .where(field, isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where(field, isLessThan: Timestamp.fromDate(until));
    Future<int> countOf(Query<Map<String, dynamic>> query) async =>
        (await query.count().get()).count ?? 0;

    final joined = between(
      users,
      _createdAtField,
    ).orderBy(_createdAtField, descending: true);
    final deleted = between(
      users.where(_deletedField, isEqualTo: true),
      UserRecord.deletedAtField,
    );
    final joinedUsers = joined.where(_roleField, isEqualTo: userRole);
    final joinedHosts = joined.where(_roleField, isEqualTo: hostRole);
    const bonusAmountField = UserRecord.welcomeBonusAmountField;

    final results = await Future.wait<Object>([
      countOf(joinedUsers),
      countOf(joinedUsers.where(_deletedField, isEqualTo: true)),
      countOf(joinedHosts),
      countOf(joinedHosts.where(_deletedField, isEqualTo: true)),
      countOf(deleted.where(_roleField, isEqualTo: userRole)),
      countOf(deleted.where(_roleField, isEqualTo: hostRole)),
      deleted.aggregate(sum(UserRecord.walletBalanceField)).get(),
      between(
        users,
        UserRecord.welcomeBonusClaimedAtField,
      ).aggregate(count(), sum(bonusAmountField)).get(),
    ]);
    final deletedWallets = results[6] as AggregateQuerySnapshot;
    final welcomeBonuses = results[7] as AggregateQuerySnapshot;
    return UserAccountTotals(
      activeUsers: (results[0] as int) - (results[1] as int),
      activeHosts: (results[2] as int) - (results[3] as int),
      deletedUsers: results[4] as int,
      deletedHosts: results[5] as int,
      deletedWalletBalance:
          deletedWallets.getSum(UserRecord.walletBalanceField) ?? 0,
      bonusUsers: welcomeBonuses.count ?? 0,
      bonusAmount: welcomeBonuses.getSum(bonusAmountField) ?? 0,
    );
  }

  Future<UserAccountTotals> _allTimeAccountTotals() async {
    final users = _firestore.collection(_collection);
    final results = await Future.wait<Object>([
      _roleCounts(userRole),
      _roleCounts(hostRole),
      users
          .where(_deletedField, isEqualTo: true)
          .aggregate(sum(UserRecord.walletBalanceField))
          .get(),
      users
          .where(_bonusField, isGreaterThan: 0)
          .aggregate(count(), sum(_bonusField))
          .get(),
    ]);
    final (totalUsers, deletedUsers) = results[0] as (int, int);
    final (totalHosts, deletedHosts) = results[1] as (int, int);
    final deletedWallets = results[2] as AggregateQuerySnapshot;
    final bonuses = results[3] as AggregateQuerySnapshot;
    return UserAccountTotals(
      activeUsers: totalUsers - deletedUsers,
      activeHosts: totalHosts - deletedHosts,
      deletedUsers: deletedUsers,
      deletedHosts: deletedHosts,
      deletedWalletBalance:
          deletedWallets.getSum(UserRecord.walletBalanceField) ?? 0,
      bonusUsers: bonuses.count ?? 0,
      bonusAmount: bonuses.getSum(_bonusField) ?? 0,
    );
  }

  Future<Either<Failure, RecordPage<UserRecord>>> fetchUsersPage(
    String role,
    RecordPageQuery query, {
    required int pageSize,
    bool onlyBlocked = false,
    bool onlyDeleted = false,
    String? deletedBy,
  }) => RecordPages.fetch(
    _usersOfRole(
      role,
      onlyBlocked: onlyBlocked,
      onlyDeleted: onlyDeleted,
      deletedBy: deletedBy,
    ),
    query,
    UserRecord.fromDocument,
    sortField: _createdAtField,
    pageSize: pageSize,
  );

  Future<Either<Failure, List<UserRecord>>> searchUsers(
    String role,
    String term, {
    DateTime? from,
    bool onlyBlocked = false,
    bool onlyDeleted = false,
    String? deletedBy,
  }) async {
    final base = _usersOfRole(
      role,
      onlyBlocked: onlyBlocked,
      onlyDeleted: onlyDeleted,
      deletedBy: deletedBy,
    );
    try {
      final snapshots = await Future.wait([
        for (final (field, prefix) in UserSearch.prefixes(
          term,
          isHost: role == hostRole,
        ))
          base
              .where(field, isGreaterThanOrEqualTo: prefix)
              .where(field, isLessThan: '$prefix${UserSearch.prefixEnd}')
              .orderBy(field)
              .limit(UserSearch.maxResultsPerPrefix)
              .get(),
      ]);
      final records =
          <String, UserRecord>{
            for (final snapshot in snapshots)
              for (final document in snapshot.docs)
                document.id: UserRecord.fromDocument(
                  document.id,
                  document.data(),
                ),
          }.values.where((record) {
            final createdAt = record.createdAt;
            return from == null ||
                (createdAt != null && !createdAt.isBefore(from));
          }).toList();
      final oldest = DateTime.fromMillisecondsSinceEpoch(0);
      records.sort(
        (a, b) => (b.createdAt ?? oldest).compareTo(a.createdAt ?? oldest),
      );
      return right(records);
    } on FirebaseException catch (error) {
      return left(FirestoreFailures.read(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  Query<Map<String, dynamic>> _usersOfRole(
    String role, {
    required bool onlyBlocked,
    required bool onlyDeleted,
    String? deletedBy,
  }) {
    var query = _firestore
        .collection(_collection)
        .where(_roleField, isEqualTo: role);
    if (onlyBlocked) query = query.where(_blockedField, isEqualTo: true);
    if (onlyDeleted) query = query.where(_deletedField, isEqualTo: true);
    if (deletedBy != null) {
      query = query.where(UserRecord.deletedByField, isEqualTo: deletedBy);
    }
    return query;
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
      _revision?.bump();
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
    if (failure != null) return left(failure);
    _revision?.bump();
    return right(unit);
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

  Future<Either<Failure, Unit>> markDeletedByAdmin(String id) =>
      updateRecord(id, {
        _deletedField: true,
        UserRecord.deletedByField: UserRecord.deletedByAdmin,
        UserRecord.deletedAtField: FieldValue.serverTimestamp(),
      });
}
