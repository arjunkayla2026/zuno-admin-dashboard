import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_header.dart';

class RechargeDialogHeader extends StatelessWidget {
  const RechargeDialogHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AppDialogHeader(
      title: title,
      subtitle: subtitle,
      icon: SvgPicture.asset(
        AppImages.rechargeIcon,
        width: AppDialogHeader.iconSize,
        height: AppDialogHeader.iconSize,
        colorFilter: const ColorFilter.mode(
          AppColors.primaryDark,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
