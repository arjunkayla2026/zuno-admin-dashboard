import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_lookup_state.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/repositories/host_management_repository.dart';

class HostLookupCubit extends Cubit<HostLookupState> {
  HostLookupCubit(this._repository, {required this.hostId})
    : super(const HostLookupState());

  final HostManagementRepository _repository;
  final String hostId;

  Future<void> load() async {
    emit(const HostLookupState());
    final result = await _repository.findHost(hostId);
    if (isClosed) return;
    emit(
      result.match(
        (failure) => HostLookupState(
          status: LoadStatus.failure,
          errorMessage: failure.message,
        ),
        (host) => HostLookupState(status: LoadStatus.loaded, host: host),
      ),
    );
  }
}
