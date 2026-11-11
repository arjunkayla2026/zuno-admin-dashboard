import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/enums/wallet_adjustment_type.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

class UserManagementRepository {
  const UserManagementRepository(this._dataSource);

  static const String _role = 'user';
  static const int _pageSize = 10;

  final UsersRemoteDataSource _dataSource;

  Future<Either<Failure, RecordPage<AdminUser>>> fetchUsers({
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
      if (name != user.name) 'name': name,
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
}
