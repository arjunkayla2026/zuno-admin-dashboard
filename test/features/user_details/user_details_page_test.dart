import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_segmented_control.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/pages/user_details_page.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/pages/user_management_page.dart';

void main() {
  Future<void> pumpDetails(
    WidgetTester tester, [
    Size size = const Size(1728, 1116),
  ]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const UserDetailsPage()),
    );
  }

  Future<void> openRechargeTab(WidgetTester tester) async {
    await tester.ensureVisible(find.text(AppStrings.rechargeHistory));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.rechargeHistory));
    await tester.pump();
  }

  testWidgets('shows the profile, stats and call history by default', (
    tester,
  ) async {
    await pumpDetails(tester);

    expect(find.text('Arjun Nair'), findsOneWidget);
    expect(find.text('₹2,943'), findsOneWidget);
    expect(find.text('2,098'), findsOneWidget);
    expect(find.text('Pinkky'), findsOneWidget);
    expect(find.text('7 calls'), findsOneWidget);
    expect(find.text('Showing 7 of 7'), findsOneWidget);
  });

  testWidgets('segmented controls size to their labels', (tester) async {
    await pumpDetails(tester);

    final controls = find.byWidgetPredicate(
      (widget) => widget is AppSegmentedControl,
    );
    expect(controls, findsNWidgets(2));
    for (final element in controls.evaluate()) {
      expect(tester.getSize(find.byWidget(element.widget)).height, 40);
      expect(
        tester.getSize(find.byWidget(element.widget)).width,
        lessThan(420),
      );
    }
  });

  testWidgets('type filter narrows the calls', (tester) async {
    await pumpDetails(tester);

    await tester.tap(find.text(AppStrings.video).first);
    await tester.pump();

    expect(find.text('3 calls'), findsOneWidget);
    expect(find.text('Divya'), findsNothing);
    expect(find.text('Showing 3 of 7'), findsOneWidget);
  });

  testWidgets('single date filters to that day', (tester) async {
    await pumpDetails(tester);

    await tester.tap(find.text(AppStrings.singleDate));
    await tester.pump();

    expect(find.text('2 calls'), findsOneWidget);
    expect(find.text('Divya'), findsNothing);
    expect(find.text('10/05/2026'), findsNothing);
  });

  testWidgets('recharge tab shows its table and toolbar', (tester) async {
    await pumpDetails(tester);
    await openRechargeTab(tester);

    expect(find.text('pay_xcW3YMVz9c'), findsOneWidget);
    expect(find.text('ADM-F7V82UZV'), findsOneWidget);
    expect(find.text(AppStrings.addRecharge), findsOneWidget);
    expect(find.text(AppStrings.completed), findsNWidgets(7));
    expect(find.text('Pinkky'), findsNothing);
  });

  testWidgets('recharge search matches payment ID and amount', (tester) async {
    await pumpDetails(tester);
    await openRechargeTab(tester);

    await tester.enterText(find.byType(TextField), 'PAY_XC');
    await tester.pump();
    expect(find.text('Showing 1 of 7'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '₹999');
    await tester.pump();
    expect(find.text('Showing 2 of 7'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nothing');
    await tester.pump();
    expect(find.text(AppStrings.noRecordsFound), findsOneWidget);
  });

  testWidgets('tapping a user row opens details and back returns', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1728, 1116);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        initialRoute: AppRoutes.userManagement,
        routes: AppRoutes.routes,
      ),
    );

    await tester.tap(find.text('Rahul Menon'));
    await tester.pumpAndSettle();

    expect(find.byType(UserDetailsPage), findsOneWidget);
    expect(find.text('ZU10232'), findsOneWidget);
    expect(find.text('347'), findsOneWidget);

    await tester.tap(find.text(AppStrings.backToUsers));
    await tester.pumpAndSettle();

    expect(find.byType(UserDetailsPage), findsNothing);
    expect(find.byType(UserManagementPage), findsOneWidget);
  });

  testWidgets('sidebar user management leaves the details page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1728, 1116);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        initialRoute: AppRoutes.userDetails,
        routes: AppRoutes.routes,
      ),
    );

    await tester.tap(find.text(AppStrings.userManagement).first);
    await tester.pumpAndSettle();

    expect(find.byType(UserManagementPage), findsOneWidget);
  });

  for (final size in const [Size(1024, 700), Size(768, 900), Size(390, 844)]) {
    testWidgets('both tabs avoid overflow at ${size.width}', (tester) async {
      await pumpDetails(tester, size);
      expect(tester.takeException(), isNull);

      await openRechargeTab(tester);
      expect(tester.takeException(), isNull);
      expect(find.text(AppStrings.addRecharge), findsOneWidget);
    });
  }
}
