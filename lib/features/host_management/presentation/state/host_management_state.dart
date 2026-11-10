import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/call_pricing.dart';

enum HostFilter { today, all, newHosts, blocked, deletedByAdmin, deletedByUser }

class HostManagementState {
  const HostManagementState({
    required this.hosts,
    required this.pricing,
    this.status = LoadStatus.loaded,
    this.errorMessage,
    this.filter = HostFilter.today,
    this.query = '',
    this.page = 1,
  });

  static const int pageSize = 12;

  final List<AdminHost> hosts;
  final CallPricing pricing;
  final LoadStatus status;
  final String? errorMessage;
  final HostFilter filter;
  final String query;
  final int page;

  List<AdminHost> get filteredHosts {
    final term = query.trim().toLowerCase();
    final digits = term.replaceAll(' ', '');
    return hosts.where((host) {
      final matchesFilter = switch (filter) {
        HostFilter.today || HostFilter.all => true,
        HostFilter.newHosts => host.isNew,
        HostFilter.blocked => host.status == HostStatus.blocked,
        HostFilter.deletedByAdmin => host.status == HostStatus.deletedByAdmin,
        HostFilter.deletedByUser => host.status == HostStatus.deletedByUser,
      };
      if (!matchesFilter) return false;
      if (term.isEmpty) return true;
      return host.name.toLowerCase().contains(term) ||
          host.fullName.toLowerCase().contains(term) ||
          host.hostId.toLowerCase().contains(term) ||
          host.userID.toLowerCase().contains(term) ||
          (digits.isNotEmpty &&
              host.phone.replaceAll(' ', '').contains(digits));
    }).toList();
  }

  bool get showsPricing => filter == HostFilter.today;

  int get totalPages {
    final count = filteredHosts.length;
    if (count == 0) return 1;
    return (count / pageSize).ceil();
  }

  int get firstIndex => (page - 1) * pageSize;

  List<AdminHost> get pageHosts =>
      filteredHosts.skip(firstIndex).take(pageSize).toList();

  HostManagementState copyWith({
    List<AdminHost>? hosts,
    CallPricing? pricing,
    LoadStatus? status,
    String? errorMessage,
    HostFilter? filter,
    String? query,
    int? page,
  }) {
    return HostManagementState(
      hosts: hosts ?? this.hosts,
      pricing: pricing ?? this.pricing,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      page: page ?? this.page,
    );
  }
}
