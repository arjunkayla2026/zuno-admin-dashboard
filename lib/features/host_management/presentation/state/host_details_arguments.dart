import 'package:flutter/foundation.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';

class HostDetailsArguments {
  const HostDetailsArguments({required this.host, this.onHostChanged});

  final AdminHost host;
  final ValueChanged<AdminHost>? onHostChanged;
}
