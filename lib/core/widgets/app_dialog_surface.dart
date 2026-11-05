import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.modalScrim,
    transitionDuration: Duration.zero,
    pageBuilder: (context, _, _) => Center(child: builder(context)),
  );
}

class AppDialogSurface extends StatelessWidget {
  const AppDialogSurface({
    super.key,
    required this.padding,
    required this.child,
  });

  static const double _width = 500;

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppUtils.spacingLg),
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: _width,
          padding: padding,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusTile),
            boxShadow: AppColors.dialogShadows,
          ),
          child: child,
        ),
      ),
    );
  }
}
