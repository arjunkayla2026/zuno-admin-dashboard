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

class CallsTable extends StatelessWidget {
  const CallsTable({
    super.key,
    required this.calls,
    required this.firstNumber,
    required this.onCallTap,
  });

  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.number, 69),
    AppTableColumn(AppStrings.date, 101),
    AppTableColumn(AppStrings.userName, 131),
    AppTableColumn(AppStrings.hostName, 124),
    AppTableColumn(AppStrings.callType, 96),
    AppTableColumn(AppStrings.callInitiatedTime, 127),
    AppTableColumn(AppStrings.callStartTime, 108),
    AppTableColumn(AppStrings.callEndTime, 99),
    AppTableColumn(AppStrings.callDuration, 98),
    AppTableColumn(AppStrings.callEndedBy, 160),
    AppTableColumn(AppStrings.callStatus, 120),
    AppTableColumn(AppStrings.userSpendCoinsAmount, 160, alignEnd: true),
    AppTableColumn(AppStrings.spendInrChat, 112, alignEnd: true),
    AppTableColumn(AppStrings.hostRevenue, 100, alignEnd: true),
    AppTableColumn(AppStrings.totalHostRevenue, 140, alignEnd: true),
    AppTableColumn(AppStrings.adminRevenue, 116, alignEnd: true),
    AppTableColumn(AppStrings.totalAdminRevenue, 150, alignEnd: true),
    AppTableColumn('', 24),
    AppTableColumn(AppStrings.callId, 196),
  ];

  static final int columnCount = _columns.length;

  final List<CallLog> calls;
  final int firstNumber;
  final ValueChanged<CallLog> onCallTap;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);
    final strong = cell.copyWith(fontWeight: FontWeight.w700);
    final mono = AppTextStyles.monoSmall.copyWith(color: textColor);

    return AppDataTable(
      columns: _columns,
      onRowTap: (index) => onCallTap(calls[index]),
      rows: [
        for (final (index, call) in calls.indexed)
          () {
            final (statusLabel, status) = CallLogLabels.status(call);
            final duration = call.durationSeconds;
            final startedAt = call.startedAt;
            final endedAt = call.endedAt;
            return [
              Text('${firstNumber + index}', style: cell),
              Text(DateFormatter.short(call.initiatedAt), style: cell),
              Text(call.userName, style: cell),
              Text(call.hostName, style: strong),
              AppStatusBadge(
                label: CallLogLabels.type(call.type),
                status: AppStatus.isNew,
              ),
              Text(
                DateFormatter.timeWithSeconds(call.initiatedAt),
                style: cell,
              ),
              Text(
                startedAt == null
                    ? AppStrings.emptyValue
                    : DateFormatter.timeWithSeconds(startedAt),
                style: cell,
              ),
              Text(
                endedAt == null
                    ? AppStrings.emptyValue
                    : DateFormatter.timeWithSeconds(endedAt),
                style: cell,
              ),
              Text(
                duration == null
                    ? AppStrings.emptyValue
                    : DateFormatter.shortDuration(duration),
                style: cell,
              ),
              Text(CallLogLabels.endedBy(call), style: cell),
              AppStatusBadge(label: statusLabel, status: status),
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
              Text(
                NumberFormatter.rupeesAmount(call.hostEarnings),
                style: strong,
              ),
              Text(
                AppStrings.perMinute(
                  NumberFormatter.rupeesAmount(call.adminRatePerMinute),
                ),
                style: strong,
              ),
              Text(
                NumberFormatter.rupeesAmount(call.adminRevenue),
                style: strong,
              ),
              const SizedBox.shrink(),
              Text(call.callId, style: mono),
            ];
          }(),
      ],
    );
  }
}
