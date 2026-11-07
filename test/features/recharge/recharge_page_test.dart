import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_filter_dropdown.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_pagination.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_stat_cards.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/pages/recharge_page.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/state/recharge_state.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/widgets/recharge_details_sheet.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, [
    Size size = const Size(1728, 1116),
  ]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const RechargePage()),
    );
  }

  Finder stat(String value) => find.descendant(
    of: find.byType(AppStatCards),
    matching: find.text(value),
  );

  Future<void> choose(WidgetTester tester, String current, String next) async {
    await tester.tap(find.text(current).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(next).last);
    await tester.pumpAndSettle();
  }

  testWidgets('stats and first page match the reference', (tester) async {
    await pumpPage(tester);

    expect(stat('53'), findsOneWidget);
    expect(stat('₹19,847'), findsOneWidget);
    expect(stat('₹850'), findsOneWidget);
    expect(stat('₹170'), findsOneWidget);
    expect(find.text('Showing 1–11 of 71'), findsOneWidget);
    expect(find.text('ADM-WWQDENH7'), findsOneWidget);
    expect(find.text('pay_xUFwtVn4e8'), findsOneWidget);
    expect(find.text('2,900'), findsOneWidget);
  });

  testWidgets('pagination shows seven pages', (tester) async {
    await pumpPage(tester);

    await tester.tap(
      find.descendant(of: find.byType(AppPagination), matching: find.text('7')),
    );
    await tester.pump();

    expect(find.text('Showing 67–71 of 71'), findsOneWidget);
  });

  Future<void> chooseIn<T>(WidgetTester tester, String option) async {
    await tester.tap(find.byType(AppFilterDropdown<T>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  testWidgets('source menu lists the four sources', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byType(AppFilterDropdown<RechargeSourceFilter>));
    await tester.pumpAndSettle();
    for (final label in [
      AppStrings.adminRecharges,
      AppStrings.adminCreditDebit,
      AppStrings.gatewayPayments,
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('admin credit & debit updates the stats', (tester) async {
    await pumpPage(tester);
    await chooseIn<RechargeSourceFilter>(tester, AppStrings.adminCreditDebit);

    expect(stat('0'), findsOneWidget);
    expect(stat('₹850'), findsOneWidget);
    expect(stat('₹170'), findsOneWidget);
    expect(find.text('Showing 1–11 of 18'), findsOneWidget);
  });

  testWidgets('admin recharges hide gateway payments', (tester) async {
    await pumpPage(tester);
    await chooseIn<RechargeSourceFilter>(tester, AppStrings.adminRecharges);

    expect(find.text(AppStrings.razorpay), findsNothing);
    expect(find.text('ADM-A413F7EK'), findsOneWidget);
  });

  testWidgets('status filter keeps failed payments', (tester) async {
    await pumpPage(tester);
    await chooseIn<RechargeStatusFilter>(tester, AppStrings.failed);

    expect(find.text(AppStrings.completed), findsNothing);
    expect(find.text(AppStrings.failed), findsWidgets);
  });

  testWidgets('row opens the recharge details sheet', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('ADM-WWQDENH7'));
    await tester.pumpAndSettle();
    Finder inSheet(String text) => find.descendant(
      of: find.byType(RechargeDetailsSheet),
      matching: find.text(text),
    );

    expect(inSheet(AppStrings.rechargeDetails), findsOneWidget);
    expect(inSheet(AppStrings.adminRecharges), findsOneWidget);
    expect(inSheet('ZU10231'), findsOneWidget);
    expect(inSheet('₹199'), findsNWidgets(2));
    expect(inSheet('550'), findsNWidgets(2));

    await tester.tap(inSheet(AppStrings.close));
    await tester.pumpAndSettle();
    expect(find.byType(RechargeDetailsSheet), findsNothing);
  });

  testWidgets('view user opens user details', (tester) async {
    tester.view.physicalSize = const Size(1728, 1116);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.recharge,
      ),
    );

    await tester.tap(find.text('ADM-WWQDENH7'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.viewUser));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.backToUsers), findsOneWidget);
  });

  testWidgets('view user is disabled for unknown users', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('pay_xUFwtVn4e8'));
    await tester.pumpAndSettle();
    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, AppStrings.viewUser),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('date filter and order search narrow the list', (tester) async {
    await pumpPage(tester);
    await choose(tester, AppStrings.filters, AppStrings.last7Days);
    expect(find.text(AppStrings.last7Days), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'order_zkdeX29XqY');
    await tester.pump();
    expect(find.text('Showing 1–1 of 1'), findsOneWidget);
  });

  testWidgets('sidebar opens the recharge page', (tester) async {
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

    await tester.tap(find.text(AppStrings.recharge));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.totalRechargeCount), findsOneWidget);
  });

  for (final width in [1024.0, 768.0, 390.0]) {
    testWidgets('no overflow at $width', (tester) async {
      await pumpPage(tester, Size(width, 900));
      expect(tester.takeException(), isNull);
    });
  }
}
