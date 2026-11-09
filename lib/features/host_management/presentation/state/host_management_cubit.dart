import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/mock/host_mock_data.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/call_pricing.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/repositories/host_management_repository.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_management_state.dart';

class HostManagementCubit extends Cubit<HostManagementState> {
  HostManagementCubit(this._repository)
    : super(
        const HostManagementState(
          hosts: [],
          pricing: HostMockData.pricing,
          status: LoadStatus.loading,
        ),
      );

  final HostManagementRepository _repository;

  Future<void> loadHosts() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final result = await _repository.fetchHosts();
    if (isClosed) return;

    result.match(
      (failure) => emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (hosts) => emit(
        state.copyWith(status: LoadStatus.loaded, hosts: hosts, page: 1),
      ),
    );
  }

  void search(String query) => emit(state.copyWith(query: query, page: 1));

  void selectFilter(HostFilter filter) =>
      emit(state.copyWith(filter: filter, page: 1));

  void goToPage(int page) => emit(state.copyWith(page: page));

  void updatePricing(CallPricing pricing) =>
      emit(state.copyWith(pricing: pricing));

  void replaceHost(AdminHost replacement) {
    final hosts = [
      for (final current in state.hosts)
        current.hostId == replacement.hostId ? replacement : current,
    ];
    _showHosts(hosts);
    refreshHosts();
  }

  Future<void> refreshHosts() async {
    final result = await _repository.fetchHosts();
    if (isClosed) return;
    result.match((_) {}, _showHosts);
  }

  void _showHosts(List<AdminHost> hosts) {
    final updated = state.copyWith(hosts: hosts);
    emit(
      updated.page > updated.totalPages
          ? updated.copyWith(page: updated.totalPages)
          : updated,
    );
  }
}
