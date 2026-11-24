import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/enums/wallet_adjustment_type.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/datasources/recharge_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

class UserManagementRepository {
  const UserManagementRepository(this._dataSource, {this._recharges});

  static const String _role = 'user';
  static const int _pageSize = 10;

  final UsersRemoteDataSource _dataSource;
  final RechargeRemoteDataSource? _recharges;

  Future<Either<Failure, RecordPage<AdminUser>>> fetchUsers({
    UserStatus? status,
    String? term,
    Object? cursor,
  }) async {
    final result = await _fetchUsersPage(
      status: status,
      term: term,
      cursor: cursor,
    );
    return switch (result) {
      Right(value: final page) => right(await _withRechargeCounts(page)),
      Left() => result,
    };
  }

  /// Fills in each user's completed recharge count. A failed count leaves
  /// the users unchanged (shown as "—") rather than failing the page.
  Future<RecordPage<AdminUser>> _withRechargeCounts(
    RecordPage<AdminUser> page,
  ) async {
    final recharges = _recharges;
    if (recharges == null || page.items.isEmpty) return page;
    final result = await recharges.fetchCompletedRechargeCounts(
      page.items.map((user) => user.id),
    );
    return result.match(
      (_) => page,
      (counts) => page.mapItems(
        (users) => [
          for (final user in users)
            if (counts[user.id] case final count?)
              user.copyWith(recharges: count)
            else
              user,
        ],
      ),
    );
  }

  Future<Either<Failure, RecordPage<AdminUser>>> _fetchUsersPage({
    UserStatus? status,
    String? term,
    Object? cursor,
  }) async {
    final from = status == UserStatus.newUser
        ? UserRecord.newAccountCutoff
        : null;
    final onlyBlocked = status == UserStatus.blocked;
    final onlyDeleted =
        status == UserStatus.deletedByAdmin ||
        status == UserStatus.deletedByUser;
    final deletedBy = status == UserStatus.deletedByAdmin
        ? UserRecord.deletedByAdmin
        : null;
    Iterable<AdminUser> select(List<UserRecord> records) => records
        .map(AdminUser.fromRecord)
        .where((user) => status == null || user.status == status);

    if (term != null) {
      if (cursor case LocalPageCursor<AdminUser>(:final remaining)) {
        return right(RecordPages.local(remaining, _pageSize));
      }
      final result = await _dataSource.searchUsers(
        _role,
        term,
        from: from,
        onlyBlocked: onlyBlocked,
        onlyDeleted: onlyDeleted,
        deletedBy: deletedBy,
      );
      return result.map(
        (records) => RecordPages.local(select(records).toList(), _pageSize),
      );
    }

    return RecordPages.untilMatch(
      cursor,
      (next) => _dataSource.fetchUsersPage(
        _role,
        RecordPageQuery(from: from, cursor: next),
        pageSize: _pageSize,
        onlyBlocked: onlyBlocked,
        onlyDeleted: onlyDeleted,
        deletedBy: deletedBy,
      ),
      select,
    );
  }

  Future<Either<Failure, Unit>> updateDetails(
    AdminUser user, {
    required String name,
    required String phone,
  }) async {
    final phoneFields = phone == user.phone
        ? const <String, Object?>{}
        : UserRecord.phoneFields(phone);
    if (phoneFields == null) {
      return left(const DataFailure(AppStrings.enterValidPhone));
    }

    return _dataSource.updateRecord(user.id, {
      // The user app reads and edits `userName`; `name` is a legacy field.
      if (name != user.name) 'userName': name,
      ...phoneFields,
    });
  }

  Future<Either<Failure, Unit>> setBlocked(
    AdminUser user, {
    required bool blocked,
  }) => _dataSource.setBlocked(user.id, blocked: blocked);

  Future<Either<Failure, Unit>> adjustWallet(
    AdminUser user, {
    required WalletAdjustmentType type,
    required int amount,
    required String description,
  }) {
    final isCredit = type == WalletAdjustmentType.credit;
    return _dataSource.adjustWallet(
      user.id,
      isCredit: isCredit,
      amount: amount,
      ledgerCollection: RechargeTransaction.collection,
      ledgerEntry: (adminUid) => RechargeTransaction.adminAdjustmentFields(
        userId: user.id,
        isCredit: isCredit,
        amount: amount,
        description: description,
        adminUid: adminUid,
      ),
    );
  }

  Future<Either<Failure, Unit>> delete(AdminUser user) =>
      _dataSource.markDeletedByAdmin(user.id);

  /// The user's current document, or null when it no longer exists.
  Future<Either<Failure, AdminUser?>> fetchUser(String id) async {
    final result = await _dataSource.fetchByIds([id]);
    return result.map(
      (records) => records.isEmpty ? null : AdminUser.fromRecord(records.first),
    );
  }

  Future<Either<Failure, AdminUser?>> findUser(String id) async {
    final result = await _dataSource.fetchByIds([id]);
    return result.map(
      (records) => switch (records) {
        [final record, ...] when record.role == _role => AdminUser.fromRecord(
          record,
        ),
        _ => null,
      },
    );
  }

  Future<Either<Failure, double>> fetchDeletedAccountProfit(AdminUser user) =>
      user.hasActions
      ? Future.value(right(0))
      : _dataSource.fetchDeletedAccountProfit(user.id);
}
