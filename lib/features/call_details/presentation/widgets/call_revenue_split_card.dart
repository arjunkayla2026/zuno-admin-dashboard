import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_card.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_detail_grid.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';

class CallRevenueSplitCard extends StatelessWidget {
  const CallRevenueSplitCard({super.key, required this.call});

  final CallLog call;

  @override
  Widget build(BuildContext context) {
    return AppLabeledCard(
      label: AppStrings.revenueSplit,
      child: AppDetailGrid(
        items: [
          AppDetailItem(
            AppStrings.hostRevenue,
            value: AppStrings.perMinute(
              NumberFormatter.rupeesAmount(call.hostRatePerMinute),
            ),
          ),
          AppDetailItem(
            AppStrings.totalHostRevenue,
            value: NumberFormatter.rupeesAmount(call.hostEarnings),
          ),
          AppDetailItem(
            AppStrings.adminRevenue,
            value: AppStrings.perMinute(
              NumberFormatter.rupeesAmount(call.adminRatePerMinute),
            ),
          ),
          AppDetailItem(
            AppStrings.totalAdminRevenue,
            value: NumberFormatter.rupeesAmount(call.adminRevenue),
          ),
          AppDetailItem(AppStrings.callId, value: call.callId, mono: true),
        ],
      ),
    );
  }
}
