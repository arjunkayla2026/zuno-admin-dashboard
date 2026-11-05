import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/pages/admin_login_page.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:zuno_admin_dashboard/main.dart';

void main() {
  Future<void> pumpDashboard(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const DashboardPage()),
    );
  }

  Future<void> selectCustomRange(WidgetTester tester) async {
    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.customDateRange).last);
    await tester.pumpAndSettle();
  }

  testWidgets('shows today by default without date fields', (tester) async {
    await pumpDashboard(tester, const Size(1728, 1116));

    expect(find.text('₹18,460'), findsOneWidget);
    expect(find.text('10/22/2026'), findsNothing);
  });

  testWidgets('custom range shows date fields, labels and values', (
    tester,
  ) async {
    await pumpDashboard(tester, const Size(1728, 1116));
    await selectCustomRange(tester);

    expect(find.text('10/22/2026'), findsOneWidget);
    expect(find.text('11/04/2026'), findsOneWidget);
    expect(find.text('22 Oct 2026 – 04 Nov 2026'), findsNWidgets(3));
    expect(find.text('₹2,45,518'), findsOneWidget);
    expect(find.text('₹18,460'), findsNothing);
  });

  testWidgets('switching back to today restores its values', (tester) async {
    await pumpDashboard(tester, const Size(1728, 1116));
    await selectCustomRange(tester);

    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.today).last);
    await tester.pumpAndSettle();

    expect(find.text('₹18,460'), findsOneWidget);
    expect(find.text('10/22/2026'), findsNothing);
  });

  for (final size in const [Size(1024, 700), Size(768, 900), Size(390, 844)]) {
    testWidgets('custom range does not overflow at ${size.width}', (
      tester,
    ) async {
      await pumpDashboard(tester, size);
      await selectCustomRange(tester);

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('narrow screens move the sidebar into a drawer', (tester) async {
    await pumpDashboard(tester, const Size(390, 844));
    expect(find.text(AppStrings.hostManagement), findsNothing);

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.hostManagement), findsOneWidget);
  });

  testWidgets('login stays the initial route and dashboard is routable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1728, 1116);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyApp());
    expect(find.byType(AdminLoginPage), findsOneWidget);

    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed(AppRoutes.dashboard);
    await tester.pumpAndSettle();

    expect(find.byType(DashboardPage), findsOneWidget);
  });
}
