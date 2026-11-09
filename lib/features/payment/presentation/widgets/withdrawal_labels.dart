import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

abstract final class WithdrawalLabels {
  static (String, AppStatus) status(Withdrawal withdrawal) =>
      withdrawal.isPending
      ? (AppStrings.pending, AppStatus.pending)
      : (AppStrings.success, AppStatus.active);
}
