import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/wallet_transaction.dart';

class HostWalletHistoryTable extends StatelessWidget {
  const HostWalletHistoryTable({super.key, required this.transactions});

  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.date, 300),
    AppTableColumn(AppStrings.creditDebit, 200),
    AppTableColumn(AppStrings.amount, 150, alignEnd: true),
    AppTableColumn('', 27),
    AppTableColumn(AppStrings.description, 300),
    AppTableColumn(AppStrings.status, 120),
  ];

  final List<WalletTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cell = AppTextStyles.bodySmall.copyWith(
      color: context.colorScheme.onSurface,
    );

    return AppDataTable(
      columns: _columns,
      rows: [
        for (final transaction in transactions)
          [
            Text(DateFormatter.short(transaction.date), style: cell),
            AppStatusBadge(
              label: transaction.isCredit
                  ? AppStrings.credit
                  : AppStrings.debit,
              status: transaction.isCredit ? AppStatus.active : AppStatus.error,
            ),
            Text(
              AppStrings.signedAmount(
                NumberFormatter.rupees(transaction.amount),
                isCredit: transaction.isCredit,
              ),
              style: cell.copyWith(
                fontWeight: FontWeight.w700,
                color: transaction.isCredit
                    ? colors.activeText
                    : colors.errorText,
              ),
            ),
            const SizedBox.shrink(),
            Text(transaction.description, style: cell),
            const AppStatusBadge(
              label: AppStrings.success,
              status: AppStatus.active,
            ),
          ],
      ],
    );
  }
}
