import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_sidebar_submenu.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_pagination.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_take_action_button.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/pages/host_management_page.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/call_pricing_dialog.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, [
    Size size = const Size(1728, 1116),
  ]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const HostManagementPage()),
    );
  }

  Future<void> chooseAction(WidgetTester tester, String label) async {
    await tester.tap(find.byType(AppTakeActionButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('first page matches the reference', (tester) async {
    await pumpPage(tester);

    expect(find.text('Nandana Suresh'), findsOneWidget);
    expect(find.text('Lakshmi Priya'), findsOneWidget);
    expect(find.text('₹2,818'), findsOneWidget);
    expect(find.text('Showing 1–12 of 30'), findsOneWidget);
    expect(find.text(AppStrings.noActions), findsNWidgets(2));
    expect(find.text(AppStrings.newLabel), findsOneWidget);
    expect(find.text(AppStrings.setCallMessagePrice), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AdminSidebarSubmenu),
        matching: find.text(AppStrings.hostList),
      ),
      findsOneWidget,
    );
  });

  for (final width in [1024.0, 768.0, 390.0]) {
    testWidgets('no overflow at $width', (tester) async {
      await pumpPage(tester, Size(width, 900));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('pagination moves to the next page', (tester) async {
    await pumpPage(tester);

    await tester.tap(
      find.descendant(of: find.byType(AppPagination), matching: find.text('2')),
    );
    await tester.pump();

    expect(find.text('Nandana'), findsNothing);
    expect(find.text('Showing 13–24 of 30'), findsOneWidget);
  });

  testWidgets('filter menu filters the table and hides the rates', (
    tester,
  ) async {
    await pumpPage(tester);
    expect(find.text(AppStrings.today), findsOneWidget);
    expect(find.text('Audio 1 coin/sec'), findsOneWidget);

    await tester.tap(find.text(AppStrings.today));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.newUsers));
    await tester.pumpAndSettle();

    expect(find.text('Kavya Ramesh'), findsOneWidget);
    expect(find.text('Nandana Suresh'), findsNothing);
    expect(find.text('Showing 1–1 of 1'), findsOneWidget);
    expect(find.text('Audio 1 coin/sec'), findsNothing);
    expect(find.text('Message 2 coins'), findsNothing);
  });

  testWidgets('search matches host ID and phone digits', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'zh10294');
    await tester.pump();
    expect(find.text('Pinkky Raj'), findsOneWidget);
    expect(find.text('Nandana Suresh'), findsNothing);

    await tester.enterText(find.byType(TextField), '8982297');
    await tester.pump();
    expect(find.text('Nandana Suresh'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nobody');
    await tester.pump();
    expect(find.text(AppStrings.noHostsFound), findsOneWidget);
  });

  testWidgets('block confirms then marks the host blocked', (tester) async {
    await pumpPage(tester);
    await chooseAction(tester, AppStrings.block);

    expect(find.text('Block Nandana?'), findsOneWidget);
    await tester.tap(find.text(AppStrings.blockHostAction));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.blocked), findsNWidgets(2));
  });

  testWidgets('delete removes the actions for that host', (tester) async {
    await pumpPage(tester);
    await chooseAction(tester, AppStrings.delete);

    await tester.tap(find.text(AppStrings.deleteAccountAction));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noActions), findsNWidgets(3));
  });

  testWidgets('edit saves the new name', (tester) async {
    await pumpPage(tester);
    await chooseAction(tester, AppStrings.edit);

    expect(find.byType(AppSideSheet), findsOneWidget);
    await tester.enterText(
      find
          .descendant(
            of: find.byType(AppSideSheet),
            matching: find.byType(TextField),
          )
          .first,
      'Nandu',
    );
    await tester.tap(find.text(AppStrings.saveChanges));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.hostDetailsUpdated), findsOneWidget);

    await tester.tap(find.text(AppStrings.done));
    await tester.pumpAndSettle();
    expect(find.text('Nandu'), findsOneWidget);
  });

  testWidgets('pricing dialog saves new rates to the toolbar summary', (
    tester,
  ) async {
    await pumpPage(tester);
    expect(find.text(AppStrings.audioRateSummary(1)), findsOneWidget);
    expect(find.text('Audio 1 coin/sec'), findsOneWidget);

    await tester.tap(find.text(AppStrings.setCallMessagePrice));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.pricingSubtitle), findsOneWidget);

    final fields = find.descendant(
      of: find.byType(CallPricingDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), '3');
    await tester.enterText(fields.at(2), '');
    await tester.pump();
    final save = find.widgetWithText(ElevatedButton, AppStrings.savePrices);
    expect(tester.widget<ElevatedButton>(save).onPressed, isNull);

    await tester.enterText(fields.at(2), '5x');
    await tester.pump();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.byType(CallPricingDialog), findsNothing);
    expect(find.text('Audio 3 coins/sec'), findsOneWidget);
    expect(find.text('Message 5 coins'), findsOneWidget);
  });

  testWidgets('pricing dialog fits a narrow screen', (tester) async {
    await pumpPage(tester, const Size(390, 800));
    await tester.tap(find.text(AppStrings.setCallMessagePrice));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a row opens host details', (tester) async {
    tester.view.physicalSize = const Size(1728, 1116);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.hostManagement,
      ),
    );

    await tester.tap(find.text('Neena Thomas'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.backToHosts), findsOneWidget);
    expect(find.text('Neena Thomas'), findsWidgets);
    expect(find.text(AppStrings.hostUploadedDocuments), findsOneWidget);
  });
}
