import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/widgets/recharge_labels.dart';

class RechargeHistoryTable extends StatelessWidget {
  const RechargeHistoryTable({super.key, required this.transactions});

  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.date, 115),
    AppTableColumn(AppStrings.time, 93),
    AppTableColumn(AppStrings.type, 150),
    AppTableColumn(AppStrings.rechargeAmount, 137, alignEnd: true),
    AppTableColumn(AppStrings.adminCreditAmount, 169, alignEnd: true),
    AppTableColumn(AppStrings.adminDebitAmount, 165, alignEnd: true),
    AppTableColumn(AppStrings.receivedCoins, 123, alignEnd: true),
    AppTableColumn('', 23),
    AppTableColumn(AppStrings.paymentId, 146),
    AppTableColumn(AppStrings.orderId, 163),
    AppTableColumn(AppStrings.paymentGateway, 120),
    AppTableColumn(AppStrings.status, 125),
  ];

  final List<RechargeTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);
    final strong = cell.copyWith(fontWeight: FontWeight.w700);
    final mono = AppTextStyles.monoSmall.copyWith(color: textColor);

    return AppDataTable(
      columns: _columns,
      rows: [
        for (final transaction in transactions)
          () {
            final (statusLabel, status) = RechargeLabels.status(
              transaction.status,
            );
            return [
              Text(RechargeLabels.date(transaction), style: cell),
              Text(RechargeLabels.time(transaction), style: cell),
              Text(RechargeLabels.source(transaction), style: cell),
              Text(
                RechargeLabels.amountFor(transaction, RechargeKind.recharge),
                style: strong,
              ),
              Text(
                RechargeLabels.amountFor(transaction, RechargeKind.credit),
                style: cell,
              ),
              Text(
                RechargeLabels.amountFor(transaction, RechargeKind.debit),
                style: cell,
              ),
              Text(RechargeLabels.coins(transaction), style: cell),
              const SizedBox.shrink(),
              Text(transaction.paymentId ?? AppStrings.emptyValue, style: mono),
              Text(transaction.displayOrderId, style: mono),
              Text(RechargeLabels.gateway(transaction.gateway), style: cell),
              AppStatusBadge(label: statusLabel, status: status),
            ];
          }(),
      ],
    );
  }
}
