import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/settings_tabs_card.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(26, 20, 26, 32);
  static const EdgeInsets _mobilePadding = EdgeInsets.all(AppUtils.spacingLg);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppUtils.isMobile(context) ? _mobilePadding : _padding,
      child: const SettingsTabsCard(),
    );
  }
}
