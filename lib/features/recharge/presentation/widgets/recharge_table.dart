import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/widgets/recharge_details_sheet.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/widgets/recharge_labels.dart';

class RechargeTable extends StatelessWidget {
  const RechargeTable({super.key, required this.transactions});

  static const double _avatarGap = 8;
  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.date, 100),
    AppTableColumn(AppStrings.time, 82),
    AppTableColumn(AppStrings.name, 169),
    AppTableColumn(AppStrings.phoneNumber, 137),
    AppTableColumn(AppStrings.rechargeAmount, 106, alignEnd: true),
    AppTableColumn(AppStrings.adminCreditAmount, 149, alignEnd: true),
    AppTableColumn(AppStrings.adminDebitAmount, 143, alignEnd: true),
    AppTableColumn(AppStrings.receivedCoins, 111, alignEnd: true),
    AppTableColumn('', 20),
    AppTableColumn(AppStrings.paymentId, 130),
    AppTableColumn(AppStrings.orderId, 143),
    AppTableColumn(AppStrings.paymentGateway, 120),
    AppTableColumn(AppStrings.status, 120),
  ];

  final List<RechargeTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);
    final strong = cell.copyWith(fontWeight: FontWeight.w700);
    final mono = AppTextStyles.monoSmall.copyWith(color: textColor);
    const palette = AppColors.avatarPalette;

    return AppDataTable(
      columns: _columns,
      onRowTap: (index) => showRechargeDetails(context, transactions[index]),
      rows: [
        for (final transaction in transactions)
          () {
            final (statusLabel, status) = RechargeLabels.status(
              transaction.status,
            );
            return [
              Text(RechargeLabels.date(transaction), style: cell),
              Text(RechargeLabels.time(transaction), style: cell),
              Row(
                children: [
                  AppInitialsAvatar(
                    initials: transaction.initials,
                    color: palette[transaction.avatarIndex % palette.length],
                    textStyle: AppTextStyles.captionSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: _avatarGap),
                  Expanded(child: Text(transaction.userName, style: strong)),
                ],
              ),
              Text(transaction.phone, style: mono),
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
