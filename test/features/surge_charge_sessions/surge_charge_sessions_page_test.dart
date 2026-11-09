import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_switch.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_take_action_button.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/pages/surge_charge_sessions_page.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/widgets/surge_session_sheet.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, [
    Size size = const Size(1728, 1116),
  ]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const SurgeChargeSessionsPage()),
    );
  }

  Finder sheetField(int index) => find
      .descendant(
        of: find.byType(SurgeSessionSheet),
        matching: find.byType(TextField),
      )
      .at(index);

  Future<void> chooseAction(WidgetTester tester, int row, String label) async {
    await tester.tap(find.byType(AppTakeActionButton).at(row));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('lists the reference sessions', (tester) async {
    await pumpPage(tester);

    expect(find.text(AppStrings.peakHourSurgeCharges), findsOneWidget);
    expect(find.text('Session 1'), findsOneWidget);
    expect(find.text('07:00 PM'), findsOneWidget);
    expect(find.text('11:59 PM'), findsOneWidget);
    expect(find.text('+30%'), findsOneWidget);
    expect(find.text('Peak hours · +10% surge charge'), findsOneWidget);
    expect(find.text(AppStrings.enabled), findsNWidgets(2));
    expect(find.text(AppStrings.disabled), findsOneWidget);
  });

  testWidgets('toggling a switch updates the status badge', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byType(AppStatusSwitch).last);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.enabled), findsNWidgets(3));
    expect(find.text(AppStrings.disabled), findsNothing);
  });

  testWidgets('create session validates then adds a row', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text(AppStrings.createSession));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.createSurgeSession), findsOneWidget);
    expect(find.text('08:00 PM'), findsOneWidget);
    expect(
      find.textContaining('+0% surge charge', findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.text(AppStrings.saveSession));
    await tester.pump();
    expect(find.text(AppStrings.enterSurgeCharge), findsOneWidget);

    await tester.enterText(sheetField(2), '15');
    await tester.pump();
    expect(
      find.textContaining('+15% surge charge', findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.text(AppStrings.saveSession));
    await tester.pumpAndSettle();

    expect(find.byType(SurgeSessionSheet), findsNothing);
    expect(find.text('Session 4'), findsOneWidget);
    expect(find.text('+15%'), findsOneWidget);
  });

  testWidgets('edit updates the session', (tester) async {
    await pumpPage(tester);
    await chooseAction(tester, 0, AppStrings.edit);

    expect(find.text(AppStrings.editSurgeSession), findsOneWidget);
    expect(find.text(AppStrings.block), findsNothing);
    await tester.enterText(sheetField(2), '25');
    await tester.tap(find.text(AppStrings.saveSession));
    await tester.pumpAndSettle();

    expect(find.text('+25%'), findsOneWidget);
    expect(find.text('+20%'), findsNothing);
  });

  testWidgets('remove asks for confirmation', (tester) async {
    await pumpPage(tester);
    await chooseAction(tester, 2, AppStrings.delete);

    expect(find.text(AppStrings.removeSurgeSessionTitle), findsOneWidget);
    expect(
      find.text(
        'The 12:00 PM – 02:00 PM session (+10%) will stop applying and be '
        'removed.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text(AppStrings.removeSession));
    await tester.pumpAndSettle();

    expect(find.text('Session 3'), findsNothing);
    expect(find.text('+10%'), findsNothing);
  });

  testWidgets('host list button opens the page', (tester) async {
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

    await tester.tap(
      find.widgetWithText(OutlinedButton, AppStrings.surgeChargeSessions),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.peakHourSurgeCharges), findsOneWidget);

    await tester.tap(find.text(AppStrings.backToHosts));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.peakHourSurgeCharges), findsNothing);
  });

  for (final width in [1024.0, 768.0, 390.0]) {
    testWidgets('no overflow at $width', (tester) async {
      await pumpPage(tester, Size(width, 900));
      expect(tester.takeException(), isNull);
    });

    testWidgets('sheet fits at $width', (tester) async {
      await pumpPage(tester, Size(width, 900));
      await tester.tap(find.text(AppStrings.createSession));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
