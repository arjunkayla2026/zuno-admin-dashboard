import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/approval_tabs_card.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/approval_toolbar.dart';

class ApprovalContent extends StatelessWidget {
  const ApprovalContent({super.key});

  static const double _toolbarGap = 10;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(32, 24, 32, 32);
  static const EdgeInsets _mobilePadding = EdgeInsets.all(AppUtils.spacingLg);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppUtils.isMobile(context) ? _mobilePadding : _padding,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ApprovalToolbar(),
          SizedBox(height: _toolbarGap),
          ApprovalTabsCard(),
        ],
      ),
    );
  }
}
