import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class MockWithdrawalBadge extends StatelessWidget {
  const MockWithdrawalBadge({super.key});

  static Widget? of(Withdrawal withdrawal) =>
      withdrawal.isMock ? const MockWithdrawalBadge() : null;

  @override
  Widget build(BuildContext context) {
    return const AppStatusBadge(
      label: AppStrings.mockBadge,
      status: AppStatus.pending,
    );
  }
}
