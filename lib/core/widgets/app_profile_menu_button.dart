import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_action_menu.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_anchored_menu.dart';

class AppProfileMenuButton extends StatelessWidget {
  const AppProfileMenuButton({
    super.key,
    required this.onSelected,
    this.actions = AppActionMenu.defaultActions,
  });

  static const double _iconSize = 24;
  static const double _menuRightOffset = 6;
  static const double _menuTopOffset = 39;

  final ValueChanged<AppMenuAction> onSelected;
  final List<AppMenuAction> actions;

  Future<void> _openMenu(BuildContext context) async {
    final size = AppActionMenu.sizeFor(actions);
    final action = await showAnchoredMenu<AppMenuAction>(
      anchorContext: context,
      size: size,
      position: (anchor) => Offset(
        anchor.center.dx + _menuRightOffset - size.width,
        anchor.center.dy + _menuTopOffset,
      ),
      builder: (_) => AppActionMenu(actions: actions),
    );
    if (action == null || !context.mounted) return;
    onSelected(action);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _openMenu(context),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: const Icon(Icons.more_vert_rounded, size: _iconSize),
    );
  }
}
