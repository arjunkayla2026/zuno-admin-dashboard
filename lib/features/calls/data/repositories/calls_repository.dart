import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/calls/data/datasources/calls_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_participant.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_revenue.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_statistics.dart';

class CallsRepository {
  const CallsRepository(this._calls, this._users);

  static const int pageSize = 10;

  final CallsRemoteDataSource _calls;
  final UsersRemoteDataSource _users;

  Future<Either<Failure, RecordPage<CallLog>>> fetchPage({
    DateTime? from,
    DateTime? until,
    String? status,
    bool lowBalanceOnly = false,
    String? callType,
    CallParticipant? participant,
    Object? cursor,
  }) => _calls.fetchPage(
    from: from,
    until: until,
    status: status,
    lowBalanceOnly: lowBalanceOnly,
    callType: callType,
    participant: participant,
    cursor: cursor,
    pageSize: pageSize,
  );

  Future<Either<Failure, int>> count({
    DateTime? from,
    DateTime? until,
    String? status,
    bool lowBalanceOnly = false,
    String? callType,
    CallParticipant? participant,
  }) => _calls.count(
    from: from,
    until: until,
    status: status,
    lowBalanceOnly: lowBalanceOnly,
    callType: callType,
    participant: participant,
  );

  Future<Either<Failure, CallStatistics>> fetchStatistics({
    DateTime? from,
    DateTime? until,
  }) => _calls.fetchStatistics(from: from, until: until);

  Future<Either<Failure, CallRevenue>> fetchRevenue({
    DateTime? from,
    DateTime? until,
  }) => _calls.fetchRevenue(from: from, until: until);

  /// Firestore document IDs cannot contain `/`, so only text without
  /// slashes or spaces is looked up as a call ID.
  static bool isPossibleCallId(String text) =>
      text.isNotEmpty && !text.contains('/') && !text.contains(RegExp(r'\s'));

  /// The call with exactly this document ID, from any date, joined to its
  /// user for the phone number; null when there is none.
  Future<Either<Failure, CallLog?>> findCallWithUser(String callId) async {
    if (!isPossibleCallId(callId)) return right(null);
    final result = await _calls.fetchById(callId);
    return result.fold((failure) async => left(failure), (call) async {
      if (call == null) return right(null);
      final joined = await _joinUsers([call]);
      return joined.map((calls) => calls.first);
    });
  }

  Future<Either<Failure, List<CallLog>>> fetchCallsWithUsers({
    DateTime? from,
    DateTime? until,
  }) async {
    final result = await _calls.fetchCalls(from: from, until: until);
    return result.fold((failure) async => left(failure), _joinUsers);
  }

  Future<Either<Failure, List<CallLog>>> _joinUsers(List<CallLog> calls) async {
    final users = await _users.fetchByIds(calls.map((call) => call.customerId));
    return users.map((records) {
      final byId = {for (final record in records) record.id: record};
      return [for (final call in calls) call.withUser(byId[call.customerId])];
    });
  }
}
