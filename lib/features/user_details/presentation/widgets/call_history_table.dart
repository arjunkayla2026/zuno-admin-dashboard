import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/models/call_record.dart';

class CallHistoryTable extends StatelessWidget {
  const CallHistoryTable({super.key, required this.calls});

  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.date, 101),
    AppTableColumn(AppStrings.hostName, 86),
    AppTableColumn(AppStrings.type, 88),
    AppTableColumn(AppStrings.callInitiatedTime, 125),
    AppTableColumn(AppStrings.callStartTime, 107),
    AppTableColumn(AppStrings.callEndTime, 103),
    AppTableColumn(AppStrings.callEndedBy, 152),
    AppTableColumn(AppStrings.callStatus, 136),
    AppTableColumn(AppStrings.callDuration, 84),
    AppTableColumn(AppStrings.userSpendCoinsAmount, 165, alignEnd: true),
    AppTableColumn(AppStrings.totalUserSpendAmount, 168, alignEnd: true),
    AppTableColumn(AppStrings.hostRevenue, 100, alignEnd: true),
  ];

  final List<CallRecord> calls;

  static String _typeLabel(CallType type) => switch (type) {
    CallType.audio => AppStrings.audio,
    CallType.video => AppStrings.video,
  };

  static (String, AppStatus) _status(CallStatus status) => switch (status) {
    CallStatus.completed => (AppStrings.completed, AppStatus.active),
    CallStatus.rejected => (AppStrings.rejected, AppStatus.error),
    CallStatus.notAnswered => (AppStrings.notAnswered, AppStatus.pending),
    CallStatus.lowBalance => (AppStrings.lowBalance, AppStatus.pending),
  };

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);
    final strong = cell.copyWith(fontWeight: FontWeight.w700);

    return AppDataTable(
      columns: _columns,
      rows: [
        for (final call in calls)
          () {
            final (statusLabel, status) = _status(call.status);
            return [
              Text(DateFormatter.short(call.date), style: cell),
              Text(call.hostName, style: strong),
              AppStatusBadge(
                label: _typeLabel(call.type),
                status: AppStatus.isNew,
              ),
              Text(call.initiatedTime, style: cell),
              Text(call.startTime ?? AppStrings.emptyValue, style: cell),
              Text(call.endTime, style: cell),
              Text(call.endedBy, style: cell),
              AppStatusBadge(label: statusLabel, status: status),
              Text(call.duration ?? AppStrings.emptyValue, style: cell),
              Text(call.spendCoins, style: cell),
              Text(call.totalSpend, style: strong),
              Text(call.hostRevenue, style: strong),
            ];
          }(),
      ],
    );
  }
}
