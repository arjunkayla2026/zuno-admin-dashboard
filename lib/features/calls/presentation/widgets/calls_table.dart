import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
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
    AppTableColumn(AppStrings.callInitiatedTime, 127),
    AppTableColumn(AppStrings.callStartTime, 108),
    AppTableColumn(AppStrings.callEndTime, 99),
    AppTableColumn(AppStrings.callDuration, 98),
    AppTableColumn(AppStrings.callEndedBy, 160),
    AppTableColumn(AppStrings.userSpendCoinsAmount, 160, alignEnd: true),
    AppTableColumn(AppStrings.spendInrChat, 112, alignEnd: true),
    AppTableColumn(AppStrings.hostRevenue, 106, alignEnd: true),
  ];

  static final int columnCount = _columns.length;

  final List<CallLog> calls;
  final int firstNumber;
  final ValueChanged<CallLog> onCallTap;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final muted = context.appColors.textSecondary;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);
    final strong = cell.copyWith(fontWeight: FontWeight.w700);

    return AppDataTable(
      columns: _columns,
      onRowTap: (index) => onCallTap(calls[index]),
      rows: [
        for (final (index, call) in calls.indexed)
          () {
            final duration = call.durationSeconds;
            final startedAt = call.startedAt;
            return [
              Text('${firstNumber + index}', style: cell),
              Text(DateFormatter.short(call.initiatedAt), style: cell),
              Text(call.userName, style: cell),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: call.hostName, style: strong),
                    TextSpan(
                      text: AppStrings.hostWithCallType(
                        CallLogLabels.type(call.type),
                      ),
                      style: cell.copyWith(color: muted),
                    ),
                  ],
                ),
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
              Text(DateFormatter.timeWithSeconds(call.endedAt), style: cell),
              Text(
                duration == null
                    ? AppStrings.emptyValue
                    : DateFormatter.shortDuration(duration),
                style: cell,
              ),
              Text(call.endedBy, style: cell),
              Text(NumberFormatter.grouped(call.spendCoins), style: cell),
              Text(
                NumberFormatter.rupeesDecimal(call.spendRupees),
                style: strong,
              ),
              Text(
                AppStrings.perMinute(
                  NumberFormatter.rupees(call.hostRatePerMinute),
                ),
                style: strong,
              ),
            ];
          }(),
      ],
    );
  }
}
