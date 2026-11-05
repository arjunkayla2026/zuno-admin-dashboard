import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_section_card.dart';
import 'package:zuno_admin_dashboard/features/dashboard/data/models/recharge_activity.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/widgets/recharge_table.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/widgets/view_all_button.dart';

class RecentRechargeCard extends StatelessWidget {
  const RecentRechargeCard({super.key, required this.recharges});

  static const double _headerHeight = 60;

  final List<RechargeActivity> recharges;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: AppStrings.recentRechargeActivity,
      headerHeight: _headerHeight,
      trailing: const ViewAllButton(label: AppStrings.viewAllRecharges),
      child: RechargeTable(recharges: recharges),
    );
  }
}
