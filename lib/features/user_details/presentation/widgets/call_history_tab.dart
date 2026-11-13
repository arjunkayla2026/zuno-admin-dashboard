import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/widgets/call_history_panel.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/call_history_table.dart';

class CallHistoryTab extends StatelessWidget {
  const CallHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CallHistoryPanel(
      tableBuilder: (calls) => CallHistoryTable(calls: calls),
    );
  }
}
