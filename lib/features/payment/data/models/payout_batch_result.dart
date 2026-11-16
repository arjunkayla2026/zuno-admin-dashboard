import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class PayoutItemResult {
  const PayoutItemResult({
    required this.payoutId,
    required this.ok,
    this.error,
    this.totalAmount = 0,
    this.receipt,
  });

  static PayoutItemResult? fromMap(Object? value) {
    if (value is! Map) return null;
    final payoutId = value['payoutId'];
    if (payoutId is! String) return null;
    final ok = value['ok'] == true;
    final error = value['error'];
    final total = value['totalAmount'];
    return PayoutItemResult(
      payoutId: payoutId,
      ok: ok,
      error: error is String ? error : null,
      totalAmount: total is num ? total.toDouble() : 0,
      receipt: ok && value['tdsPercent'] is num
          ? PayoutReceipt.fromMap(Map<Object?, Object?>.from(value))
          : null,
    );
  }

  final String payoutId;
  final bool ok;
  final String? error;
  final double totalAmount;
  final PayoutReceipt? receipt;
}

class PayoutFailure {
  const PayoutFailure(this.withdrawal, this.message);

  final Withdrawal withdrawal;
  final String message;
}

class PayoutBatchResult {
  const PayoutBatchResult({this.succeeded = const [], this.failed = const []});

  final List<Withdrawal> succeeded;
  final List<PayoutFailure> failed;

  bool get hasSuccess => succeeded.isNotEmpty;

  double get succeededTotal =>
      succeeded.fold(0, (total, withdrawal) => total + withdrawal.totalAmount);

  PayoutBatchResult merge(PayoutBatchResult other) => PayoutBatchResult(
    succeeded: [...succeeded, ...other.succeeded],
    failed: [...failed, ...other.failed],
  );
}
