import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_action_menu.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_anchored_menu.dart';

class AppTakeActionButton extends StatelessWidget {
  const AppTakeActionButton({
    super.key,
    required this.onSelected,
    this.actions = AppActionMenu.defaultActions,
  });

  static const double _iconSize = 15;
  static const double _hitPadding = 6;
  static const double _menuTopOffset = 15;

  final ValueChanged<AppMenuAction> onSelected;
  final List<AppMenuAction> actions;

  Future<void> _openMenu(BuildContext context) async {
    final size = AppActionMenu.sizeFor(actions);
    final action = await showAnchoredMenu<AppMenuAction>(
      anchorContext: context,
      size: size,
      position: (anchor) => Offset(
        anchor.center.dx - size.width / 2,
        anchor.center.dy - _menuTopOffset,
      ),
      builder: (_) => AppActionMenu(actions: actions),
    );
    if (action == null || !context.mounted) return;
    onSelected(action);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: AppStrings.takeAction,
      child: Builder(
        builder: (anchorContext) => InkResponse(
          onTap: () => _openMenu(anchorContext),
          child: Padding(
            padding: const EdgeInsets.all(_hitPadding),
            child: SvgPicture.asset(
              AppImages.takeActionIcon,
              width: _iconSize,
              height: _iconSize,
              colorFilter: const ColorFilter.mode(
                AppColors.tableActionIcon,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
