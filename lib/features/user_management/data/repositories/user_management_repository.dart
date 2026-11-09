import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

class UserManagementRepository {
  const UserManagementRepository(this._dataSource);

  static const String _role = 'user';

  final UsersRemoteDataSource _dataSource;

  Future<Either<Failure, List<AdminUser>>> fetchUsers() async {
    final result = await _dataSource.fetchByRole(_role);
    return result.map((records) => records.map(AdminUser.fromRecord).toList());
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

    return _dataSource.updateRecord(user.userId, {
      if (name != user.name) 'name': name,
      ...phoneFields,
    });
  }

  Future<Either<Failure, Unit>> setBlocked(
    AdminUser user, {
    required bool blocked,
  }) => _dataSource.setBlocked(user.userId, blocked: blocked);

  Future<Either<Failure, Unit>> delete(AdminUser user) =>
      _dataSource.markDeletedByAdmin(user.userId);
}
