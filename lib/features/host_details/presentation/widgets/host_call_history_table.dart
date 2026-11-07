import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/host_call_record.dart';

class HostCallHistoryTable extends StatelessWidget {
  const HostCallHistoryTable({super.key, required this.calls});

  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.date, 101),
    AppTableColumn(AppStrings.userName, 104),
    AppTableColumn(AppStrings.hostId, 86),
    AppTableColumn(AppStrings.type, 84),
    AppTableColumn(AppStrings.callInitiatedTime, 125),
    AppTableColumn(AppStrings.callStartTime, 107),
    AppTableColumn(AppStrings.callEndTime, 103),
    AppTableColumn(AppStrings.callEndedBy, 152),
    AppTableColumn(AppStrings.callDuration, 92),
    AppTableColumn(AppStrings.callStatus, 120),
    AppTableColumn(AppStrings.userSpendCoinsAmount, 165, alignEnd: true),
    AppTableColumn(AppStrings.totalUserSpendAmount, 168, alignEnd: true),
    AppTableColumn(AppStrings.hostRevenue, 100, alignEnd: true),
  ];

  final List<HostCallRecord> calls;

  static String _typeLabel(HostCallType type) => switch (type) {
    HostCallType.audio => AppStrings.audio,
    HostCallType.video => AppStrings.video,
  };

  static (String, AppStatus) _status(HostCallStatus status) => switch (status) {
    HostCallStatus.completed => (AppStrings.completed, AppStatus.active),
    HostCallStatus.lowBalance => (AppStrings.lowBalance, AppStatus.pending),
    HostCallStatus.busy => (AppStrings.busy, AppStatus.pending),
    HostCallStatus.rejected => (AppStrings.rejected, AppStatus.error),
  };

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);
    final strong = cell.copyWith(fontWeight: FontWeight.w700);
    final mono = AppTextStyles.monoSmall.copyWith(color: textColor);

    return AppDataTable(
      columns: _columns,
      rows: [
        for (final call in calls)
          () {
            final (statusLabel, status) = _status(call.status);
            return [
              Text(DateFormatter.short(call.date), style: cell),
              Text(call.userName, style: strong),
              Text(call.userId, style: mono),
              AppStatusBadge(
                label: _typeLabel(call.type),
                status: AppStatus.isNew,
              ),
              Text(call.initiatedTime, style: cell),
              Text(call.startTime ?? AppStrings.emptyValue, style: cell),
              Text(call.endTime, style: cell),
              Text(call.endedBy, style: cell),
              Text(call.duration ?? AppStrings.emptyValue, style: cell),
              AppStatusBadge(label: statusLabel, status: status),
              Text(call.spendCoins, style: cell),
              Text(call.totalSpend, style: strong),
              Text(call.hostRevenue, style: strong),
            ];
          }(),
      ],
    );
  }
}
