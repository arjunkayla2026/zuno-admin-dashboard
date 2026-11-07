import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class AppStatusSwitch extends StatelessWidget {
  const AppStatusSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Switch(
      value: value,
      onChanged: onChanged,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      thumbColor: const WidgetStatePropertyAll(AppColors.white),
      thumbIcon: const WidgetStatePropertyAll(Icon(null)),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.activeText
            : colors.inactiveBadge,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(AppColors.transparent),
    );
  }
}
