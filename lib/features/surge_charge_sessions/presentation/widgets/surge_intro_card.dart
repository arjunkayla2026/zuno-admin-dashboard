import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_header.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/widgets/surge_session_flow.dart';

class SurgeIntroCard extends StatelessWidget {
  const SurgeIntroCard({super.key});

  static const double _sideBySideWidth = 640;
  static const double _gap = 18;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(16, 16, 16, 16);

  @override
  Widget build(BuildContext context) {
    final header = AppDialogHeader(
      title: AppStrings.peakHourSurgeCharges,
      subtitle: AppStrings.surgeIntro,
      icon: SvgPicture.asset(
        AppImages.surgeChargeIcon,
        width: AppDialogHeader.iconSize,
        height: AppDialogHeader.iconSize,
        colorFilter: const ColorFilter.mode(
          AppColors.primaryDark,
          BlendMode.srcIn,
        ),
      ),
    );
    final button = AppPrimaryButton(
      label: AppStrings.createSession,
      icon: Icons.add_rounded,
      compact: true,
      onPressed: () => createSurgeSession(context),
    );

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < _sideBySideWidth) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: _gap),
                button,
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: header),
              const SizedBox(width: _gap),
              button,
            ],
          );
        },
      ),
    );
  }
}
