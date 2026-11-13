import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/widgets/call_history_panel.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_call_history_table.dart';

class HostCallHistoryTab extends StatelessWidget {
  const HostCallHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CallHistoryPanel(
      tableBuilder: (calls) => HostCallHistoryTable(calls: calls),
    );
  }
}
