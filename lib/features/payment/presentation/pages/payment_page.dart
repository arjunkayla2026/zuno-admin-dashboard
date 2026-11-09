import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_shell.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_cubit.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/payment_state.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/payment_content.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/mock/user_mock_data.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  static AdminSubNavItem _subItem(PaymentTab tab) => switch (tab) {
    PaymentTab.withdrawalList => AdminSubNavItem.withdrawalList,
    PaymentTab.pending => AdminSubNavItem.pendingWithdrawals,
    PaymentTab.success => AdminSubNavItem.successfulWithdrawals,
  };

  static PaymentTab? _tabFor(AdminSubNavItem item) => switch (item) {
    AdminSubNavItem.withdrawalList => PaymentTab.withdrawalList,
    AdminSubNavItem.pendingWithdrawals => PaymentTab.pending,
    AdminSubNavItem.successfulWithdrawals => PaymentTab.success,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: BlocProvider(
        create: (_) => PaymentCubit(),
        child: BlocSelector<PaymentCubit, PaymentState, PaymentTab>(
          selector: (state) => state.tab,
          builder: (context, tab) => AdminShell(
            selectedItem: AdminNavItem.payment,
            selectedSubItem: _subItem(tab),
            onSubItemSelected: (item) {
              final selected = _tabFor(item);
              if (selected != null) {
                context.read<PaymentCubit>().selectTab(selected);
              }
            },
            title: AppStrings.payment,
            userName: UserMockData.adminName,
            userRole: UserMockData.adminRole,
            userInitials: UserMockData.adminInitials,
            child: const PaymentContent(),
          ),
        ),
      ),
    );
  }
}
