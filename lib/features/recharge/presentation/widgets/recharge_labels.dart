import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/state/recharge_state.dart';

abstract final class RechargeLabels {
  static String sourceFilter(RechargeSourceFilter filter) => switch (filter) {
    RechargeSourceFilter.all => AppStrings.all,
    RechargeSourceFilter.adminRecharges => AppStrings.adminRecharges,
    RechargeSourceFilter.adminCreditDebit => AppStrings.adminCreditDebit,
    RechargeSourceFilter.gatewayPayments => AppStrings.gatewayPayments,
  };

  static String statusFilter(RechargeStatusFilter filter) => switch (filter) {
    RechargeStatusFilter.all => AppStrings.all,
    RechargeStatusFilter.completed => AppStrings.completed,
    RechargeStatusFilter.failed => AppStrings.failed,
    RechargeStatusFilter.created => AppStrings.created,
  };

  static String source(RechargeTransaction transaction) {
    if (transaction.isAdminAdjustment) return AppStrings.adminCreditDebit;
    if (transaction.isGatewayPayment) return AppStrings.gatewayPayments;
    return AppStrings.adminRecharges;
  }

  static (String, AppStatus) status(RechargeStatus status) => switch (status) {
    RechargeStatus.completed => (AppStrings.completed, AppStatus.active),
    RechargeStatus.failed => (AppStrings.failed, AppStatus.error),
    RechargeStatus.created => (AppStrings.created, AppStatus.pending),
  };

  static String gateway(RechargeGateway gateway) => switch (gateway) {
    RechargeGateway.admin => AppStrings.admin,
    RechargeGateway.razorpay => AppStrings.razorpay,
  };

  static String amountLabel(RechargeKind kind) => switch (kind) {
    RechargeKind.recharge => AppStrings.rechargeAmount,
    RechargeKind.credit => AppStrings.creditAmount,
    RechargeKind.debit => AppStrings.debitAmount,
  };

  static String amountFor(RechargeTransaction transaction, RechargeKind kind) =>
      transaction.kind == kind
      ? NumberFormatter.rupeesAmount(transaction.amount)
      : AppStrings.emptyValue;

  static String date(RechargeTransaction transaction) {
    final moment = transaction.createdAt;
    return moment == null ? AppStrings.emptyValue : DateFormatter.short(moment);
  }

  static String time(RechargeTransaction transaction) {
    final moment = transaction.createdAt;
    return moment == null ? AppStrings.emptyValue : DateFormatter.time(moment);
  }

  static String coins(RechargeTransaction transaction) => transaction.coins == 0
      ? AppStrings.emptyValue
      : NumberFormatter.grouped(transaction.coins);
}
