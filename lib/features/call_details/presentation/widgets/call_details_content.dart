import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_back_link.dart';
import 'package:zuno_admin_dashboard/features/call_details/presentation/widgets/call_revenue_split_card.dart';
import 'package:zuno_admin_dashboard/features/call_details/presentation/widgets/call_summary_card.dart';
import 'package:zuno_admin_dashboard/features/call_details/presentation/widgets/call_timeline_card.dart';
import 'package:zuno_admin_dashboard/features/call_details/presentation/widgets/call_user_spend_card.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';

class CallDetailsContent extends StatelessWidget {
  const CallDetailsContent({super.key, required this.call});

  static const double _backGap = 18;
  static const double _sectionGap = 14;
  static const double _sideBySideWidth = 800;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(32, 24, 32, 32);
  static const EdgeInsets _mobilePadding = EdgeInsets.all(AppUtils.spacingLg);

  final CallLog call;

  @override
  Widget build(BuildContext context) {
    final spend = CallUserSpendCard(call: call);
    final revenue = CallRevenueSplitCard(call: call);

    return SingleChildScrollView(
      padding: AppUtils.isMobile(context) ? _mobilePadding : _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppBackLink(
            label: AppStrings.backToCalls,
            fallbackRoute: AppRoutes.calls,
          ),
          const SizedBox(height: _backGap),
          CallSummaryCard(call: call),
          const SizedBox(height: _sectionGap),
          CallTimelineCard(call: call),
          const SizedBox(height: _sectionGap),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < _sideBySideWidth) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    spend,
                    const SizedBox(height: _sectionGap),
                    revenue,
                  ],
                );
              }
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: spend),
                    const SizedBox(width: _sectionGap),
                    Expanded(child: revenue),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
