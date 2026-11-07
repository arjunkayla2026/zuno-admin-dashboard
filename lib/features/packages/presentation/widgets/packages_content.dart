import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/packages_tabs_card.dart';

class PackagesContent extends StatelessWidget {
  const PackagesContent({super.key});

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(32, 24, 32, 32);
  static const EdgeInsets _mobilePadding = EdgeInsets.all(AppUtils.spacingLg);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppUtils.isMobile(context) ? _mobilePadding : _padding,
      child: const PackagesTabsCard(),
    );
  }
}
