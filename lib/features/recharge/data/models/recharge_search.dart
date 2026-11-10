import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';

class RechargeSearch {
  const RechargeSearch({
    this.field,
    this.value,
    this.statuses,
    this.gateway,
    this.documentId,
  });

  factory RechargeSearch.parse(String raw) {
    final text = raw.trim();
    final compact = text.replaceAll(_separators, '');
    if (_amount.hasMatch(compact)) {
      return RechargeSearch(
        field: RechargeTransaction.totalAmountField,
        value: double.parse(compact),
      );
    }
    if (text.length < _minLength) return const RechargeSearch();

    final lower = text.toLowerCase();
    for (final MapEntry(:key, :value) in _statusWords.entries) {
      if (key.startsWith(lower)) return RechargeSearch(statuses: value);
    }
    for (final MapEntry(:key, :value) in _gatewayWords.entries) {
      if (key.startsWith(lower)) return RechargeSearch(gateway: value);
    }
    if (lower.startsWith(_orderPrefix)) {
      return RechargeSearch(
        field: RechargeTransaction.razorpayOrderIdField,
        value: text,
      );
    }
    if (lower.startsWith(_paymentPrefix)) {
      return RechargeSearch(
        field: RechargeTransaction.razorpayPaymentIdField,
        value: text,
      );
    }
    return RechargeSearch(documentId: text);
  }

  static const int _minLength = 2;
  static const String _orderPrefix = 'order_';
  static const String _paymentPrefix = 'pay_';
  static final RegExp _separators = RegExp(r'[\s,₹]');
  static final RegExp _amount = RegExp(r'^\d+(\.\d{1,2})?$');
  static const Map<String, List<String>> _statusWords = {
    'completed': RechargeTransaction.completedStatuses,
    'success': RechargeTransaction.completedStatuses,
    'failed': RechargeTransaction.failedStatuses,
    'created': RechargeTransaction.createdStatuses,
    'pending': RechargeTransaction.createdStatuses,
  };
  static const Map<String, RechargeGateway> _gatewayWords = {
    'razorpay': RechargeGateway.razorpay,
    'admin': RechargeGateway.admin,
  };

  final String? field;
  final Object? value;
  final List<String>? statuses;
  final RechargeGateway? gateway;
  final String? documentId;

  String get key => '$field|$value|$statuses|$gateway|$documentId';

  bool matchesGateway(RechargeTransaction transaction) =>
      gateway == null || transaction.gateway == gateway;
}
