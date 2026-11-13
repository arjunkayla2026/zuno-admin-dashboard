import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/widgets/call_log_labels.dart';

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

  final List<CallLog> calls;

  static String _time(DateTime? moment) => moment == null
      ? AppStrings.emptyValue
      : DateFormatter.timeWithSeconds(moment);

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
            final (statusLabel, status) = CallLogLabels.status(call);
            final duration = call.durationSeconds;
            return [
              Text(DateFormatter.short(call.initiatedAt), style: cell),
              Text(call.hostName, style: strong),
              AppStatusBadge(
                label: CallLogLabels.type(call.type),
                status: AppStatus.isNew,
              ),
              Text(_time(call.initiatedAt), style: cell),
              Text(_time(call.startedAt), style: cell),
              Text(_time(call.endedAt), style: cell),
              Text(CallLogLabels.endedBy(call), style: cell),
              AppStatusBadge(label: statusLabel, status: status),
              Text(
                duration == null
                    ? AppStrings.emptyValue
                    : DateFormatter.shortDuration(duration),
                style: cell,
              ),
              Text(NumberFormatter.grouped(call.spendCoins), style: cell),
              Text(
                NumberFormatter.rupeesAmount(call.spendRupees),
                style: strong,
              ),
              Text(
                AppStrings.perMinute(
                  NumberFormatter.rupeesAmount(call.hostRatePerMinute),
                ),
                style: strong,
              ),
            ];
          }(),
      ],
    );
  }
}
