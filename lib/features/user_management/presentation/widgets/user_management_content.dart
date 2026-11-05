import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/widgets/user_table_card.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/widgets/user_toolbar.dart';

class UserManagementContent extends StatelessWidget {
  const UserManagementContent({super.key});

  static const double _toolbarGap = 17;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(32, 18, 32, 32);
  static const EdgeInsets _mobilePadding = EdgeInsets.all(AppUtils.spacingLg);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppUtils.isMobile(context) ? _mobilePadding : _padding,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserToolbar(),
          SizedBox(height: _toolbarGap),
          UserTableCard(),
        ],
      ),
    );
  }
}
