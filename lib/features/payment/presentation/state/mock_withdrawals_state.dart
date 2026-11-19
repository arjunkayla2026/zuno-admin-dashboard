import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/mock_withdrawal_summary.dart';

enum MockWithdrawalsAction { none, generating, clearing }

class MockWithdrawalsState {
  const MockWithdrawalsState({
    this.status = LoadStatus.loading,
    this.summary = const MockWithdrawalSummary(),
    this.errorMessage,
    this.action = MockWithdrawalsAction.none,
    this.revision = 0,
  });

  final LoadStatus status;
  final MockWithdrawalSummary summary;
  final String? errorMessage;
  final MockWithdrawalsAction action;

  /// Goes up after every generate or clear, so the payment lists reload.
  final int revision;

  bool get isBusy => action != MockWithdrawalsAction.none;

  MockWithdrawalsState copyWith({
    LoadStatus? status,
    MockWithdrawalSummary? summary,
    String? errorMessage,
    MockWithdrawalsAction? action,
    int? revision,
  }) {
    return MockWithdrawalsState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: errorMessage ?? this.errorMessage,
      action: action ?? this.action,
      revision: revision ?? this.revision,
    );
  }
}
