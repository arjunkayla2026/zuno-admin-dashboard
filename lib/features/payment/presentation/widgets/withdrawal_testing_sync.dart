import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/mock_withdrawals_cubit.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/mock_withdrawals_state.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_cubit.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_state.dart';

/// Reloads the payment lists after mock data is generated or cleared, and the
/// testing summary after any payout action changes the tab counts.
class WithdrawalTestingSync extends StatelessWidget {
  const WithdrawalTestingSync({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MockWithdrawalsCubit, MockWithdrawalsState>(
          listenWhen: (previous, current) =>
              previous.revision != current.revision,
          listener: (context, _) => context.read<PaymentCubit>().refresh(),
        ),
        BlocListener<PaymentCubit, PaymentState>(
          listenWhen: (previous, current) =>
              previous.pendingCount != current.pendingCount ||
              previous.paidCount != current.paidCount ||
              previous.failedCount != current.failedCount,
          listener: (context, _) => context.read<MockWithdrawalsCubit>().load(),
        ),
      ],
      child: child,
    );
  }
}
