import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.sectionLabel.copyWith(
        color: context.appColors.textSecondary,
      ),
    );
  }
}
