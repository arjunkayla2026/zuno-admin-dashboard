import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';

enum HostFilter {
  today(),
  all(),
  newHosts(onlyNew: true),
  blocked(status: HostStatus.blocked),
  deletedByAdmin(status: HostStatus.deletedByAdmin),
  deletedByUser(status: HostStatus.deletedByUser);

  const HostFilter({this.status, this.onlyNew = false});

  final HostStatus? status;
  final bool onlyNew;

  bool includes(AdminHost host) =>
      (status == null || host.status == status) && (!onlyNew || host.isNew);
}

class HostManagementState {
  const HostManagementState({
    required this.hosts,
    this.status = LoadStatus.loaded,
    this.errorMessage,
    this.filter = HostFilter.today,
    this.query = '',
    this.page = 1,
    this.totalPages = 1,
    this.firstIndex = 0,
  });

  final List<AdminHost> hosts;
  final LoadStatus status;
  final String? errorMessage;
  final HostFilter filter;
  final String query;
  final int page;
  final int totalPages;
  final int firstIndex;

  bool get showsPricing => filter == HostFilter.today;

  HostManagementState copyWith({
    List<AdminHost>? hosts,
    LoadStatus? status,
    String? errorMessage,
    HostFilter? filter,
    String? query,
    int? page,
    int? totalPages,
    int? firstIndex,
  }) {
    return HostManagementState(
      hosts: hosts ?? this.hosts,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      firstIndex: firstIndex ?? this.firstIndex,
    );
  }
}
