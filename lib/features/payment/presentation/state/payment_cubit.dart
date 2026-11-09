import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/features/payment/data/mock/payment_mock_data.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit()
    : super(
        PaymentState(
          withdrawals: PaymentMockData.withdrawals,
          minimumWithdrawal: PaymentMockData.minimumWithdrawal,
          tdsPercent: PaymentMockData.tdsPercent,
          today: PaymentMockData.today,
        ),
      );

  void selectTab(PaymentTab tab) => emit(state.copyWith(tab: tab, page: 1));

  void search(String query) => emit(state.copyWith(query: query, page: 1));

  void goToPage(int page) => emit(state.copyWith(page: page));

  void markPaid(Withdrawal withdrawal) {
    final updated = state.copyWith(
      withdrawals: [
        for (final current in state.withdrawals)
          current.withdrawId == withdrawal.withdrawId
              ? current.copyWith(
                  status: WithdrawalStatus.success,
                  paidOn: state.today,
                  appliedTdsPercent: state.tdsPercent,
                )
              : current,
      ],
    );
    emit(
      updated.page > updated.totalPages
          ? updated.copyWith(page: updated.totalPages)
          : updated,
    );
  }
}
