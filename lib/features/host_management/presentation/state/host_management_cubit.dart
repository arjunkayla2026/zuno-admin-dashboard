import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/mock/host_mock_data.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/call_pricing.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_management_state.dart';

class HostManagementCubit extends Cubit<HostManagementState> {
  HostManagementCubit()
    : super(
        HostManagementState(
          hosts: HostMockData.hosts,
          pricing: HostMockData.pricing,
        ),
      );

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
    final updated = state.copyWith(hosts: hosts);
    emit(
      updated.page > updated.totalPages
          ? updated.copyWith(page: updated.totalPages)
          : updated,
    );
  }
}
