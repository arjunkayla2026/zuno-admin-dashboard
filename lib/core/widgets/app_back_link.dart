import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class AppBackLink extends StatelessWidget {
  const AppBackLink({
    super.key,
    required this.label,
    required this.fallbackRoute,
  });

  static const double _iconSize = 16;

  final String label;
  final String fallbackRoute;

  void _goBack(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(fallbackRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = context.appColors.textSecondary;

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => _goBack(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chevron_left_rounded, size: _iconSize, color: muted),
            const SizedBox(width: AppUtils.spacingXs),
            Text(label, style: AppTextStyles.bodySmall.copyWith(color: muted)),
          ],
        ),
      ),
    );
  }
}
