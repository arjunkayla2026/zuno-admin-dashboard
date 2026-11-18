import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_failure_reason.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

abstract final class WithdrawalLabels {
  static (String, AppStatus) status(Withdrawal withdrawal) =>
      switch (withdrawal.status) {
        WithdrawalStatus.open => (AppStrings.openPayout, AppStatus.inactive),
        WithdrawalStatus.pending => (AppStrings.pending, AppStatus.pending),
        WithdrawalStatus.success => (AppStrings.success, AppStatus.active),
        WithdrawalStatus.failed => (AppStrings.failed, AppStatus.error),
        WithdrawalStatus.forfeited => (AppStrings.forfeited, AppStatus.blocked),
      };

  static String failureReason(PayoutFailureReason reason) => switch (reason) {
    PayoutFailureReason.invalidAccount => AppStrings.reasonInvalidAccount,
    PayoutFailureReason.accountClosed => AppStrings.reasonAccountClosed,
    PayoutFailureReason.nameMismatch => AppStrings.reasonNameMismatch,
    PayoutFailureReason.bankRejected => AppStrings.reasonBankRejected,
    PayoutFailureReason.other => AppStrings.otherReason,
  };

  static String failure(Withdrawal withdrawal) {
    final reason = withdrawal.failureReason;
    if (reason == null) return AppStrings.emptyValue;
    final label = failureReason(reason);
    final note = withdrawal.failureNote;
    return note == null || reason.needsNote
        ? note ?? label
        : AppStrings.dotSeparated(label, note);
  }

  static (String, AppStatus) bankAccount(Withdrawal withdrawal) =>
      withdrawal.hasBankAccount
      ? (AppStrings.ready, AppStatus.active)
      : (AppStrings.noBankAccount, AppStatus.error);

  static String period(Withdrawal withdrawal) {
    final start = withdrawal.periodStart;
    final end = withdrawal.periodEnd;
    if (start == null || end == null) {
      return DateFormatter.short(withdrawal.date);
    }
    return AppStrings.periodValue(
      DateFormatter.short(start),
      DateFormatter.short(end),
    );
  }
}
