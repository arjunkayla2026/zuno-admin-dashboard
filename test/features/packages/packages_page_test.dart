import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_sidebar_submenu.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/pages/packages_page.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/package_preview_card.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/package_sheet.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, [
    Size size = const Size(1728, 1116),
  ]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const PackagesPage()),
    );
  }

  Finder sheetField(int index) => find
      .descendant(
        of: find.byType(PackageSheet),
        matching: find.byType(TextField),
      )
      .at(index);

  Finder inPreview(String text) => find.descendant(
    of: find.byType(PackagePreviewCard),
    matching: find.text(text),
  );

  Future<void> openAddSheet(WidgetTester tester) async {
    await tester.tap(find.text(AppStrings.addPackage));
    await tester.pumpAndSettle();
  }

  testWidgets('lists the reference packages', (tester) async {
    await pumpPage(tester);

    expect(find.text('5 packages · 7,583 total recharges'), findsOneWidget);
    expect(find.text('₹49'), findsNWidgets(2));
    expect(find.text('2,500'), findsOneWidget);
    expect(find.text('+200 Bonus'), findsOneWidget);
    expect(find.text('Mega pack'), findsOneWidget);
    expect(find.text('2,615'), findsOneWidget);
    expect(find.text(AppStrings.edit), findsNWidgets(5));
    expect(
      find.descendant(
        of: find.byType(AdminSidebarSubmenu),
        matching: find.text(AppStrings.packageList),
      ),
      findsOneWidget,
    );
  });

  test('GST adds 18% to the payable amount', () {
    expect(PackagePlan.payableFor(100, gst: true), 118);
    expect(PackagePlan.receivableFor(118, gst: true), 100);
    expect(PackagePlan.payableFor(199, gst: false), 199);
  });

  testWidgets('amounts fill each other in using GST', (tester) async {
    await pumpPage(tester);
    await openAddSheet(tester);

    await tester.enterText(sheetField(1), '100');
    await tester.pump();
    expect(find.text('118'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(find.text('118'), findsNWidgets(2));
  });

  testWidgets('preview updates on refresh', (tester) async {
    await pumpPage(tester);
    await openAddSheet(tester);
    expect(inPreview('₹__'), findsOneWidget);

    await tester.enterText(sheetField(0), '299');
    await tester.enterText(sheetField(2), '700');
    await tester.enterText(sheetField(3), '+80 Bonus');
    await tester.pump();
    expect(inPreview('₹__'), findsOneWidget);

    await tester.tap(find.text(AppStrings.refreshPreview));
    await tester.pump();
    expect(inPreview('₹299'), findsOneWidget);
    expect(inPreview('700'), findsOneWidget);
    expect(inPreview('+80 Bonus'), findsOneWidget);
  });

  testWidgets('saving a new package adds a row', (tester) async {
    await pumpPage(tester);
    await openAddSheet(tester);

    await tester.tap(find.text(AppStrings.savePackage));
    await tester.pump();
    expect(find.text(AppStrings.enterValue), findsNWidgets(3));

    await tester.tap(find.byType(Switch));
    await tester.enterText(sheetField(0), '299');
    await tester.enterText(sheetField(2), '700');
    await tester.enterText(sheetField(4), 'Weekend pack');
    await tester.pump();
    await tester.tap(find.text(AppStrings.savePackage));
    await tester.pumpAndSettle();

    expect(find.byType(PackageSheet), findsNothing);
    expect(find.text('Weekend pack'), findsOneWidget);
    expect(find.text('6 packages · 7,583 total recharges'), findsOneWidget);
  });

  testWidgets('editing a package shows the updated dialog', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text(AppStrings.edit).at(2));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.editPackageTitle), findsOneWidget);
    expect(find.text('₹199 · 500 coins'), findsOneWidget);
    expect(find.text(AppStrings.gstToggleTitle), findsNothing);
    expect(inPreview('₹199'), findsOneWidget);
    expect(inPreview('+50 Bonus'), findsOneWidget);

    await tester.enterText(sheetField(4), 'Top value');
    await tester.tap(find.text(AppStrings.savePackage));
    await tester.pumpAndSettle();

    expect(find.byType(PackageSheet), findsNothing);
    expect(find.text(AppStrings.packageUpdated), findsOneWidget);
    expect(find.text('₹199 for 500 coins is saved.'), findsOneWidget);

    await tester.tap(find.text(AppStrings.done));
    await tester.pumpAndSettle();
    expect(find.text('Top value'), findsOneWidget);
    expect(find.text('Best value'), findsNothing);
  });

  testWidgets('adding a package skips the updated dialog', (tester) async {
    await pumpPage(tester);
    await openAddSheet(tester);
    expect(find.text(AppStrings.packageSheetSubtitle), findsOneWidget);
    expect(find.text(AppStrings.gstToggleTitle), findsOneWidget);

    await tester.enterText(sheetField(0), '59');
    await tester.enterText(sheetField(2), '120');
    await tester.tap(find.text(AppStrings.savePackage));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.packageUpdated), findsNothing);
  });

  testWidgets('sidebar coupon list switches tab', (tester) async {
    tester.view.physicalSize = const Size(1728, 1116);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.dashboard,
      ),
    );

    await tester.tap(find.text(AppStrings.packages));
    await tester.pumpAndSettle();
    expect(find.text('Mega pack'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AdminSidebarSubmenu),
        matching: find.text(AppStrings.couponList),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Mega pack'), findsNothing);
    expect(find.text(AppStrings.couponListPendingTitle), findsOneWidget);
    expect(find.text(AppStrings.couponListPendingMessage), findsOneWidget);
  });

  for (final width in [1024.0, 768.0, 390.0]) {
    testWidgets('page and sheet fit at $width', (tester) async {
      await pumpPage(tester, Size(width, 900));
      expect(tester.takeException(), isNull);
      await openAddSheet(tester);
      expect(tester.takeException(), isNull);
    });
  }
}
