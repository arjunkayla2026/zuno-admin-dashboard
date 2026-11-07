import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_close_button.dart';

Future<T?> showAppSideSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AppColors.modalScrim,
    transitionDuration: AppSideSheet._transitionDuration,
    pageBuilder: (context, _, _) =>
        Align(alignment: Alignment.centerRight, child: builder(context)),
    transitionBuilder: (_, animation, _, child) => SlideTransition(
      position: animation
          .drive(CurveTween(curve: Curves.easeOutCubic))
          .drive(Tween(begin: const Offset(1, 0), end: Offset.zero)),
      child: child,
    ),
  );
}

class AppSideSheet extends StatelessWidget {
  const AppSideSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.footer,
  });

  static const Duration _transitionDuration = Duration(milliseconds: 200);
  static const double _width = 620;
  static const double _sidePadding = 28;
  static const double _headerHeight = 94;
  static const double _footerHeight = 70;
  static const double _closeSize = 36;
  static const double _closeIconSize = 18;
  static const double _subtitleGap = 10;
  static const double _headerTop = 22;
  static const double _titleInset = 5;
  static const EdgeInsets _bodyPadding = EdgeInsets.fromLTRB(
    _sidePadding,
    24,
    _sidePadding,
    24,
  );

  final String title;
  final String subtitle;
  final Widget body;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: _width,
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          boxShadow: AppColors.sheetShadows,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: _headerHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    _sidePadding,
                    _headerTop,
                    _sidePadding,
                    0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: _titleInset),
                            Text(
                              title,
                              style: AppTextStyles.titleSmall.copyWith(
                                color: context.colorScheme.onSurface,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: _subtitleGap),
                            Text(
                              subtitle,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: context.appColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppCloseButton(
                        size: _closeSize,
                        iconSize: _closeIconSize,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: AppColors.cardBorder),
              Expanded(
                child: SingleChildScrollView(
                  padding: _bodyPadding,
                  child: body,
                ),
              ),
              const Divider(color: AppColors.cardBorder),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: _footerHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
                  child: Align(alignment: Alignment.centerRight, child: footer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
