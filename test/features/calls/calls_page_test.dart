import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_pagination.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/pages/calls_page.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/widgets/total_calls_card.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, [
    Size size = const Size(1728, 1116),
  ]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const CallsPage()),
    );
  }

  Finder total(String count) => find.descendant(
    of: find.byType(TotalCallsCard),
    matching: find.text(count),
  );

  Future<void> choose(WidgetTester tester, String current, String next) async {
    await tester.tap(find.text(current));
    await tester.pumpAndSettle();
    await tester.tap(find.text(next).last);
    await tester.pumpAndSettle();
  }

  testWidgets('first page matches the reference', (tester) async {
    await pumpPage(tester);

    expect(total('46'), findsOneWidget);
    expect(find.text('Showing 1–12 of 46'), findsOneWidget);
    expect(find.text('Sanjay Rao'), findsOneWidget);
    expect(find.text('09:39:09 PM'), findsOneWidget);
    expect(find.text('9m 50s'), findsOneWidget);
    expect(find.text('47s'), findsOneWidget);
    expect(find.text('₹295'), findsOneWidget);
    expect(find.text('₹250.5'), findsOneWidget);
    expect(find.text('1,628'), findsOneWidget);
    expect(find.text('₹24/min'), findsNWidgets(3));
    expect(
      find.text('Scroll sideways to see all 12 call fields'),
      findsOneWidget,
    );
  });

  testWidgets('pagination moves through the 46 calls', (tester) async {
    await pumpPage(tester);

    await tester.tap(
      find.descendant(of: find.byType(AppPagination), matching: find.text('4')),
    );
    await tester.pump();

    expect(find.text('Showing 37–46 of 46'), findsOneWidget);
    expect(find.text('Joel Thomas'), findsNothing);
  });

  testWidgets('status menu lists every call status and filters', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.text(AppStrings.incomingCalls));
    await tester.pumpAndSettle();
    for (final label in [
      AppStrings.completedCalls,
      AppStrings.busyCalls,
      AppStrings.rejectedCalls,
      AppStrings.notAnsweredCalls,
      AppStrings.lowBalanceCalls,
      AppStrings.missedCalls,
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.tap(find.text(AppStrings.notAnsweredCalls));
    await tester.pumpAndSettle();

    expect(find.text('Joel Thomas'), findsNothing);
    expect(find.text('System – no answer'), findsWidgets);
    expect(find.text('System – low balance'), findsNothing);
  });

  testWidgets('type filter keeps only video calls', (tester) async {
    await pumpPage(tester);
    await choose(tester, AppStrings.callsType, AppStrings.videoCall);

    expect(find.text(AppStrings.videoCall), findsOneWidget);
    expect(find.text('Tarun Singh'), findsOneWidget);
    expect(find.text('Joel Thomas'), findsNothing);
    expect(find.text('₹12/min'), findsNothing);
  });

  testWidgets('date and period widen the range', (tester) async {
    await pumpPage(tester);

    await choose(tester, AppStrings.today, AppStrings.yesterday);
    expect(total('4'), findsOneWidget);

    await choose(tester, AppStrings.day, AppStrings.week);
    expect(total('19'), findsOneWidget);

    await choose(tester, AppStrings.yesterday, AppStrings.today);
    expect(total('65'), findsOneWidget);
  });

  testWidgets('search matches users and hosts', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'tarun');
    await tester.pump();
    expect(total('1'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nobody');
    await tester.pump();
    expect(find.text(AppStrings.noCallsFound), findsOneWidget);
  });

  testWidgets('sidebar opens the calls page', (tester) async {
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

    await tester.tap(find.text(AppStrings.calls));
    await tester.pumpAndSettle();
    expect(find.byType(TotalCallsCard), findsOneWidget);
  });

  for (final width in [1024.0, 768.0, 390.0]) {
    testWidgets('no overflow at $width', (tester) async {
      await pumpPage(tester, Size(width, 900));
      expect(tester.takeException(), isNull);
    });
  }
}
