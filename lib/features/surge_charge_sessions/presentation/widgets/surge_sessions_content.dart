import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_back_link.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/widgets/surge_intro_card.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/widgets/surge_sessions_table_card.dart';

class SurgeSessionsContent extends StatelessWidget {
  const SurgeSessionsContent({super.key});

  static const double _backGap = 18;
  static const double _sectionGap = 14;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(32, 24, 32, 32);
  static const EdgeInsets _mobilePadding = EdgeInsets.all(AppUtils.spacingLg);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppUtils.isMobile(context) ? _mobilePadding : _padding,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppBackLink(
            label: AppStrings.backToHosts,
            fallbackRoute: AppRoutes.hostManagement,
          ),
          SizedBox(height: _backGap),
          SurgeIntroCard(),
          SizedBox(height: _sectionGap),
          SurgeSessionsTableCard(),
        ],
      ),
    );
  }
}
