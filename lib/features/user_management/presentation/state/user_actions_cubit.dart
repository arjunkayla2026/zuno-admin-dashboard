import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/repositories/user_management_repository.dart';

class UserActionsCubit extends Cubit<LoadStatus> {
  UserActionsCubit(this._repository) : super(LoadStatus.loaded);

  final UserManagementRepository _repository;

  Future<String?> saveDetails(
    AdminUser user, {
    required String name,
    required String phone,
  }) => _run(() => _repository.updateDetails(user, name: name, phone: phone));

  Future<String?> setBlocked(AdminUser user, {required bool blocked}) =>
      _run(() => _repository.setBlocked(user, blocked: blocked));

  Future<String?> delete(AdminUser user) =>
      _run(() => _repository.delete(user));

  Future<String?> _run(Future<Either<Failure, Unit>> Function() write) async {
    emit(LoadStatus.loading);
    final result = await write();
    if (!isClosed) {
      emit(result.isRight() ? LoadStatus.loaded : LoadStatus.failure);
    }
    return result.getLeft().toNullable()?.message;
  }
}
