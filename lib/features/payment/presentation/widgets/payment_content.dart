import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/payment_tabs_card.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_overview_card.dart';

class PaymentContent extends StatelessWidget {
  const PaymentContent({super.key});

  static const double _sectionGap = 12;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(32, 24, 32, 32);
  static const EdgeInsets _mobilePadding = EdgeInsets.all(AppUtils.spacingLg);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppUtils.isMobile(context) ? _mobilePadding : _padding,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WithdrawalOverviewCard(),
          SizedBox(height: _sectionGap),
          PaymentTabsCard(),
        ],
      ),
    );
  }
}
