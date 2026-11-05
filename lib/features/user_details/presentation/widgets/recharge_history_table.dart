import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/models/recharge_record.dart';

class RechargeHistoryTable extends StatelessWidget {
  const RechargeHistoryTable({super.key, required this.recharges});

  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.date, 115),
    AppTableColumn(AppStrings.time, 93),
    AppTableColumn(AppStrings.type, 130),
    AppTableColumn(AppStrings.rechargeAmount, 137, alignEnd: true),
    AppTableColumn(AppStrings.adminCreditAmount, 169, alignEnd: true),
    AppTableColumn(AppStrings.adminDebitAmount, 165, alignEnd: true),
    AppTableColumn(AppStrings.receivedCoins, 123, alignEnd: true),
    AppTableColumn('', 23),
    AppTableColumn(AppStrings.paymentId, 146),
    AppTableColumn(AppStrings.orderId, 163),
    AppTableColumn(AppStrings.status, 125),
  ];

  final List<RechargeRecord> recharges;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);
    final strong = cell.copyWith(fontWeight: FontWeight.w700);
    final mono = AppTextStyles.monoSmall.copyWith(color: textColor);

    return AppDataTable(
      columns: _columns,
      rows: [
        for (final recharge in recharges)
          [
            Text(DateFormatter.short(recharge.date), style: cell),
            Text(recharge.time, style: cell),
            Text(recharge.type, style: cell),
            Text(recharge.amount, style: strong),
            Text(recharge.adminCredit ?? AppStrings.emptyValue, style: cell),
            Text(recharge.adminDebit ?? AppStrings.emptyValue, style: cell),
            Text(recharge.receivedCoins, style: cell),
            const SizedBox.shrink(),
            Text(recharge.paymentId ?? AppStrings.emptyValue, style: mono),
            Text(recharge.orderId, style: mono),
            const AppStatusBadge(
              label: AppStrings.completed,
              status: AppStatus.active,
            ),
          ],
      ],
    );
  }
}
