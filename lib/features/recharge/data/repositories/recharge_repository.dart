import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/datasources/recharge_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

class RechargeRepository {
  const RechargeRepository(this._transactions, this._users);

  final RechargeRemoteDataSource _transactions;
  final UsersRemoteDataSource _users;

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
