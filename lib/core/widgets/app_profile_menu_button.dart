import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_action_menu.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_anchored_menu.dart';

class AppProfileMenuButton extends StatelessWidget {
  const AppProfileMenuButton({super.key, required this.onSelected});

  static const double _iconSize = 24;
  static const double _menuRightOffset = 6;
  static const double _menuTopOffset = 39;

  final ValueChanged<AppMenuAction> onSelected;

  Future<void> _openMenu(BuildContext context) async {
    final action = await showAnchoredMenu<AppMenuAction>(
      anchorContext: context,
      size: AppActionMenu.size,
      position: (anchor) => Offset(
        anchor.center.dx + _menuRightOffset - AppActionMenu.size.width,
        anchor.center.dy + _menuTopOffset,
      ),
      builder: (_) => const AppActionMenu(),
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
