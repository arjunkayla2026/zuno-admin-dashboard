import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class PackageOfferTag extends StatelessWidget {
  const PackageOfferTag({super.key, required this.label});

  static const double _radius = 4;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 2,
  );

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionSmall.copyWith(
          color: colors.onPrimarySoft,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
