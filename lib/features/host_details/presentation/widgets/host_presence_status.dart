import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class HostPresenceStatus extends StatelessWidget {
  const HostPresenceStatus({super.key, required this.isOnline});

  static const double _dotSize = 6;
  static const double _dotGap = 5;

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _dotSize,
          height: _dotSize,
          decoration: BoxDecoration(
            color: isOnline ? colors.activeText : colors.inactiveText,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: _dotGap),
        Text(
          isOnline ? AppStrings.online : AppStrings.offline,
          style: AppTextStyles.labelMedium.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
