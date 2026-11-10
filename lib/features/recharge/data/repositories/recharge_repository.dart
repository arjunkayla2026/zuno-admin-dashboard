import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/datasources/recharge_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_search.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

class RechargeRepository {
  const RechargeRepository(this._transactions, this._users);

  final RechargeRemoteDataSource _transactions;
  static const int pageSize = 10;

  final UsersRemoteDataSource _users;

  Future<Either<Failure, RecordPage<RechargeTransaction>>> fetchPage({
    required bool Function(RechargeTransaction transaction) keep,
    DateTime? from,
    DateTime? until,
    List<String>? statuses,
    List<String>? types,
    Object? cursor,
  }) async {
    final result = await RecordPages.untilMatch(
      cursor,
      (next) => _transactions.fetchPage(
        from: from,
        until: until,
        statuses: statuses,
        types: types,
        cursor: next,
        pageSize: pageSize,
      ),
      (batch) => batch.where(keep),
    );
    return result.fold((failure) async => left(failure), (page) async {
      final attached = await _attachUsers(page.items);
      return attached.map(
        (items) => RecordPage(items, nextCursor: page.nextCursor),
      );
    });
  }

  Future<Either<Failure, RecordPage<RechargeTransaction>>> fetchUserHistory(
    String userId, {
    required RechargeSearch search,
    Object? cursor,
  }) async {
    final documentId = search.documentId;
    if (documentId != null) {
      final result = await _transactions.fetchById(documentId);
      return result.map(
        (transaction) => RecordPage(
          transaction != null && transaction.userId == userId
              ? [transaction]
              : const [],
        ),
      );
    }

    return RecordPages.untilMatch(
      cursor,
      (next) => _transactions.fetchPage(
        userId: userId,
        field: search.field,
        value: search.value,
        amount: search.amount,
        statuses: search.statuses,
        cursor: next,
        pageSize: pageSize,
      ),
      (batch) => batch.where(search.matchesGateway),
    );
  }

  Future<Either<Failure, UserRechargeSummary>> fetchUserSummary(
    String userId,
  ) async {
    final result = await _transactions.fetchTransactions(userId: userId);
    return result.map(UserRechargeSummary.fromTransactions);
  }

  Future<Either<Failure, RechargeTotals>> fetchTotals({
    DateTime? from,
    DateTime? until,
  }) => _transactions.fetchTotals(from: from, until: until);

  Future<Either<Failure, List<RechargeTransaction>>> fetchRecharges({
    DateTime? from,
    DateTime? until,
  }) async {
    final result = await _transactions.fetchTransactions(
      from: from,
      until: until,
    );
    return result.fold((failure) async => left(failure), _attachUsers);
  }

  Future<Either<Failure, List<RechargeTransaction>>> _attachUsers(
    List<RechargeTransaction> transactions,
  ) async {
    final result = await _users.fetchByIds(
      transactions.map((transaction) => transaction.userId),
    );
    return result.map((records) {
      final users = {
        for (final record in records) record.id: AdminUser.fromRecord(record),
      };
      return [
        for (final transaction in transactions)
          transaction.withUser(users[transaction.userId]),
      ]..sort(RechargeTransaction.newestFirst);
    });
  }
}
