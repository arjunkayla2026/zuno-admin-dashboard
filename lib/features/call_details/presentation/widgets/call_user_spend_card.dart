import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_card.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_detail_grid.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/widgets/call_log_labels.dart';

class CallUserSpendCard extends StatelessWidget {
  const CallUserSpendCard({super.key, required this.call});

  final CallLog call;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, status) = CallLogLabels.status(call.status);

    return AppLabeledCard(
      label: AppStrings.userSpend,
      child: AppDetailGrid(
        items: [
          AppDetailItem(
            AppStrings.date,
            value: DateFormatter.short(call.initiatedAt),
          ),
          AppDetailItem(
            AppStrings.callTypeField,
            value: CallLogLabels.type(call.type),
          ),
          AppDetailItem(AppStrings.userName, value: call.userName),
          AppDetailItem(AppStrings.hostName, value: call.hostName),
          AppDetailItem(
            AppStrings.userSpendCoinsAmount,
            value: AppStrings.coinsAmount(
              NumberFormatter.grouped(call.spendCoins),
            ),
          ),
          AppDetailItem(
            AppStrings.spendInrChat,
            value: NumberFormatter.rupeesDecimal(call.spendRupees),
          ),
          AppDetailItem(
            AppStrings.callStatus,
            child: AppStatusBadge(label: statusLabel, status: status),
          ),
        ],
      ),
    );
  }
}
