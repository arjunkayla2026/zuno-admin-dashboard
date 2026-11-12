import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/data_action.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';

class CallsRemoteDataSource {
  const CallsRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Query<Map<String, dynamic>> _filtered({
    DateTime? from,
    DateTime? until,
    String? status,
    bool lowBalanceOnly = false,
    String? callType,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(
      CallLog.collection,
    );
    if (status != null) {
      query = query.where(CallLog.statusField, isEqualTo: status);
    }
    if (lowBalanceOnly) {
      query = query.where(CallLog.insufficientBalanceField, isEqualTo: true);
    }
    if (callType != null) {
      query = query.where(CallLog.callTypeField, isEqualTo: callType);
    }
    if (from != null) {
      query = query.where(
        CallLog.createdAtField,
        isGreaterThanOrEqualTo: Timestamp.fromDate(from),
      );
    }
    if (until != null) {
      query = query.where(
        CallLog.createdAtField,
        isLessThan: Timestamp.fromDate(until),
      );
    }
    return query;
  }

  Future<Either<Failure, RecordPage<CallLog>>> fetchPage({
    DateTime? from,
    DateTime? until,
    String? status,
    bool lowBalanceOnly = false,
    String? callType,
    Object? cursor,
    required int pageSize,
  }) => DataAction.guard(
    'calls.fetchPage',
    () => RecordPages.fetch(
      _filtered(
        status: status,
        lowBalanceOnly: lowBalanceOnly,
        callType: callType,
      ),
      RecordPageQuery(from: from, until: until, cursor: cursor),
      CallLog.fromDocument,
      sortField: CallLog.createdAtField,
      pageSize: pageSize,
    ),
  );

  Future<Either<Failure, int>> count({
    DateTime? from,
    DateTime? until,
    String? status,
    bool lowBalanceOnly = false,
    String? callType,
  }) => DataAction.read('calls.count', () async {
    final snapshot = await _filtered(
      from: from,
      until: until,
      status: status,
      lowBalanceOnly: lowBalanceOnly,
      callType: callType,
    ).count().get();
    return snapshot.count ?? 0;
  });

  Future<Either<Failure, List<CallLog>>> fetchCalls({
    DateTime? from,
    DateTime? until,
  }) => DataAction.read('calls.fetchCalls', () async {
    final snapshot = await _filtered(
      from: from,
      until: until,
    ).orderBy(CallLog.createdAtField, descending: true).get();
    return [
      for (final document in snapshot.docs)
        CallLog.fromDocument(document.id, document.data()),
    ];
  });
}
