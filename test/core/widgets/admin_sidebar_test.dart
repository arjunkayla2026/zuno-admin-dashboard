import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_sidebar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every nav icon is a bundled asset', () async {
    for (final item in AdminNavItem.values) {
      final data = await rootBundle.load(item.svgAsset);
      expect(data.lengthInBytes, greaterThan(0));
    }
  });

  testWidgets('selected and unselected icons use the sidebar colors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1728, 1116);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AdminSidebar(
            selectedItem: AdminNavItem.calls,
            userName: 'Name',
            userRole: 'Role',
          ),
        ),
      ),
    );

    final pictures = tester.widgetList<SvgPicture>(find.byType(SvgPicture));
    expect(pictures, hasLength(AdminNavItem.values.length));

    const selected = ColorFilter.mode(
      AppColors.sidebarIconSelected,
      BlendMode.srcIn,
    );
    const unselected = ColorFilter.mode(
      AppColors.sidebarIconUnselected,
      BlendMode.srcIn,
    );
    expect(pictures.where((p) => p.colorFilter == selected), hasLength(1));
    expect(
      pictures.where((p) => p.colorFilter == unselected),
      hasLength(AdminNavItem.values.length - 1),
    );
  });
}
