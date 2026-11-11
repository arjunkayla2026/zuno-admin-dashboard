import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_sidebar_submenu.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_sidebar_tile.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_brand_logo.dart';

class AdminSidebar extends StatefulWidget {
  const AdminSidebar({
    super.key,
    required this.selectedItem,
    required this.userName,
    required this.userRole,
    this.items = AdminNavItem.values,
    this.selectedSubItem,
    this.animateSelectionChange = true,
    this.onItemSelected,
    this.onSubItemSelected,
  });

  static const double width = 264;

  final List<AdminNavItem> items;
  final AdminNavItem selectedItem;
  final String userName;
  final String userRole;
  final AdminSubNavItem? selectedSubItem;
  final bool animateSelectionChange;
  final ValueChanged<AdminNavItem>? onItemSelected;
  final ValueChanged<AdminSubNavItem>? onSubItemSelected;

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar>
    with SingleTickerProviderStateMixin {
  static const double _logoSize = 42;
  static const double _logoIconSize = 22;
  static const double _tileGap = 3;
  static const double _horizontalInset = 16;
  static const double _brandInset = 26;
  static const double _brandTop = 23;
  static const double _brandBottom = 24;
  static const String _selectionId = 'adminSidebarSelection';
  static const PageStorageKey<String> _listKey = PageStorageKey(
    'adminSidebarList',
  );

  static final PageStorageBucket _memory = PageStorageBucket();

  late final AnimationController _expansion = AnimationController(
    vsync: this,
    duration: AppTheme.pageTransitionDuration,
    value: 1,
  );
  late final CurvedAnimation _expand = CurvedAnimation(
    parent: _expansion,
    curve: AppTheme.pageTransitionCurve,
  );
  late final Animation<double> _collapse = ReverseAnimation(_expand);

  AdminNavItem? _collapsing;
  AdminNavItem? _previousSelection;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _expansion.addStatusListener(_handleExpansionStatus);
    final previous = _memory.readState(context, identifier: _selectionId);
    if (previous is AdminNavItem) _previousSelection = previous;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    final previous = _previousSelection;
    _previousSelection = null;
    if (widget.animateSelectionChange &&
        previous != null &&
        previous != widget.selectedItem) {
      _animateFrom(previous);
    }
  }

  @override
  void didUpdateWidget(AdminSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animateSelectionChange &&
        oldWidget.selectedItem != widget.selectedItem) {
      _animateFrom(oldWidget.selectedItem);
    }
  }

  void _animateFrom(AdminNavItem previous) {
    if (_reduceMotion) return;
    _collapsing = previous.subItems.isEmpty ? null : previous;
    _expansion.forward(from: 0);
  }

  void _handleExpansionStatus(AnimationStatus status) {
    if (status.isCompleted && _collapsing != null && mounted) {
      setState(() => _collapsing = null);
    }
  }

  @override
  void dispose() {
    _expand.dispose();
    _expansion.dispose();
    super.dispose();
  }

  Widget _buildItem(AdminNavItem item) {
    final selected = item == widget.selectedItem;
    final tile = AdminSidebarTile(
      item: item,
      selected: selected,
      onTap: () => widget.onItemSelected?.call(item),
    );
    final expanded = selected && item.subItems.isNotEmpty;
    final collapsing = !selected && item == _collapsing;
    if (!expanded && !collapsing) return tile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tile,
        IgnorePointer(
          ignoring: collapsing,
          child: SizeTransition(
            sizeFactor: expanded ? _expand : _collapse,
            alignment: Alignment.topLeft,
            child: AdminSidebarSubmenu(
              items: item.subItems,
              selectedItem: expanded ? widget.selectedSubItem : null,
              onItemSelected: (subItem) =>
                  widget.onSubItemSelected?.call(subItem),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.isCurrentOf(context) ?? true) {
      _memory.writeState(
        context,
        widget.selectedItem,
        identifier: _selectionId,
      );
    }
    final caption = AppTextStyles.captionSmall.copyWith(
      color: AppColors.sidebarTextUnselected,
    );

    return Container(
      width: AdminSidebar.width,
      color: AppColors.sidebarBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _brandInset,
                _brandTop,
                _brandInset,
                _brandBottom,
              ),
              child: Row(
                children: [
                  const AppBrandLogo(size: _logoSize, iconSize: _logoIconSize),
                  const SizedBox(width: AppUtils.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.appName,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        Text(AppStrings.adminPanel, style: caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageStorage(
                bucket: _memory,
                child: ListView.separated(
                  key: _listKey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: _horizontalInset,
                  ),
                  itemCount: widget.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: _tileGap),
                  itemBuilder: (_, index) => _buildItem(widget.items[index]),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: _horizontalInset),
              child: Divider(color: AppColors.sidebarDivider),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _brandInset,
                vertical: AppUtils.spacingLg,
              ),
              child: Text(
                '${AppStrings.signedInAs} ${widget.userName}\n${widget.userRole}',
                style: caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
