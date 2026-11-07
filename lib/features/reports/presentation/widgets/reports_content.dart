import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/widgets/reports_table_card.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/widgets/reports_toolbar.dart';

class ReportsContent extends StatelessWidget {
  const ReportsContent({super.key});

  static const double _toolbarGap = 30;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(32, 56, 32, 32);
  static const EdgeInsets _mobilePadding = EdgeInsets.all(AppUtils.spacingLg);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppUtils.isMobile(context) ? _mobilePadding : _padding,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReportsToolbar(),
          SizedBox(height: _toolbarGap),
          ReportsTableCard(),
        ],
      ),
    );
  }
}
