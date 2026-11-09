import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/repositories/host_management_repository.dart';

class HostActionsCubit extends Cubit<LoadStatus> {
  HostActionsCubit(this._repository) : super(LoadStatus.loaded);

  final HostManagementRepository _repository;

  Future<String?> saveDetails(AdminHost original, AdminHost edited) =>
      _run(() => _repository.updateDetails(original, edited));

  Future<String?> setBlocked(AdminHost host, {required bool blocked}) =>
      _run(() => _repository.setBlocked(host, blocked: blocked));

  Future<String?> delete(AdminHost host) =>
      _run(() => _repository.delete(host));

  Future<String?> _run(Future<Either<Failure, Unit>> Function() write) async {
    emit(LoadStatus.loading);
    final result = await write();
    if (!isClosed) {
      emit(result.isRight() ? LoadStatus.loaded : LoadStatus.failure);
    }
    return result.getLeft().toNullable()?.message;
  }
}
