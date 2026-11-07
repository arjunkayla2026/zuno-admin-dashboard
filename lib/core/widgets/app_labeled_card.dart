import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_section_label.dart';

class AppLabeledCard extends StatelessWidget {
  const AppLabeledCard({super.key, required this.label, required this.child});

  static const double _labelGap = 14;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(16, 16, 16, 18);

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionLabel(label),
          const SizedBox(height: _labelGap),
          child,
        ],
      ),
    );
  }
}
