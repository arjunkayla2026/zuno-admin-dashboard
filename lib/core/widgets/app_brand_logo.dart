import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo({super.key, required this.size, required this.iconSize});

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppUtils.radiusSmall,
      ),
      child: Icon(
        Icons.call_rounded,
        size: iconSize,
        color: AppColors.phoneIcon,
      ),
    );
  }
}
