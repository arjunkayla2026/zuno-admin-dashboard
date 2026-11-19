import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/mock_withdrawals_cubit.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/payment_tabs_card.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_overview_card.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_testing_card.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_testing_sync.dart';

class PaymentContent extends StatelessWidget {
  const PaymentContent({super.key});

  static const double _sectionGap = 12;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(32, 24, 32, 32);
  static const EdgeInsets _mobilePadding = EdgeInsets.all(AppUtils.spacingLg);

  @override
  Widget build(BuildContext context) {
    final testing = context.read<MockWithdrawalsCubit>().isAvailable;
    final content = SingleChildScrollView(
      padding: AppUtils.isMobile(context) ? _mobilePadding : _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WithdrawalOverviewCard(),
          const SizedBox(height: _sectionGap),
          const PaymentTabsCard(),
          if (testing) ...const [
            SizedBox(height: _sectionGap),
            WithdrawalTestingCard(),
          ],
        ],
      ),
    );
    return testing ? WithdrawalTestingSync(child: content) : content;
  }
}
