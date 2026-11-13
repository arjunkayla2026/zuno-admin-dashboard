import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/reports/data/models/user_report.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/widgets/report_labels.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/widgets/report_party_cell.dart';

class ReportsTable extends StatelessWidget {
  const ReportsTable({super.key, required this.reports});

  static const double _countWidth = 150;
  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.date, 179),
    AppTableColumn(AppStrings.reportedByName, 336),
    AppTableColumn(AppStrings.reported, 305),
    AppTableColumn(AppStrings.reportType, 300),
    AppTableColumn(AppStrings.receivedTotalReportCount, 190, alignEnd: true),
  ];

  final List<UserReport> reports;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);

    return AppDataTable(
      columns: _columns,
      rows: [
        for (final report in reports)
          () {
            final (typeLabel, typeStatus) = ReportLabels.type(report.type);
            return [
              Text(DateFormatter.short(report.date), style: cell),
              ReportPartyCell(party: report.reportedBy),
              ReportPartyCell(party: report.reported),
              AppStatusBadge(label: typeLabel, status: typeStatus),
              SizedBox(
                width: _countWidth,
                child: Text(
                  report.receivedTotal?.toString() ?? AppStrings.emptyValue,
                  textAlign: TextAlign.center,
                  style: cell.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ];
          }(),
      ],
    );
  }
}
