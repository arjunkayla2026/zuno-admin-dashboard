import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/calls/data/datasources/calls_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';

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
    Object? cursor,
  }) => _calls.fetchPage(
    from: from,
    until: until,
    status: status,
    lowBalanceOnly: lowBalanceOnly,
    callType: callType,
    cursor: cursor,
    pageSize: pageSize,
  );

  Future<Either<Failure, int>> count({
    DateTime? from,
    DateTime? until,
    String? status,
    bool lowBalanceOnly = false,
    String? callType,
  }) => _calls.count(
    from: from,
    until: until,
    status: status,
    lowBalanceOnly: lowBalanceOnly,
    callType: callType,
  );

  Future<Either<Failure, List<CallLog>>> fetchCallsWithUsers({
    DateTime? from,
    DateTime? until,
  }) async {
    final result = await _calls.fetchCalls(from: from, until: until);
    return result.fold((failure) async => left(failure), (calls) async {
      final users = await _users.fetchByIds(
        calls.map((call) => call.customerId),
      );
      return users.map((records) {
        final byId = {for (final record in records) record.id: record};
        return [for (final call in calls) call.withUser(byId[call.customerId])];
      });
    });
  }
}
