import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';

class HostLookupState {
  const HostLookupState({
    this.status = LoadStatus.loading,
    this.host,
    this.errorMessage,
  });

  final LoadStatus status;
  final AdminHost? host;
  final String? errorMessage;
}
