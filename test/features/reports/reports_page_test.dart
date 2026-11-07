import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_pagination.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/pages/reports_page.dart';
import 'package:zuno_admin_dashboard/features/reports/presentation/widgets/report_party_cell.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, [
    Size size = const Size(1728, 1116),
  ]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const ReportsPage()),
    );
  }

  Future<void> choose(WidgetTester tester, String current, String next) async {
    await tester.tap(find.text(current).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(next).last);
    await tester.pumpAndSettle();
  }

  int rows(WidgetTester tester) =>
      tester.widgetList(find.byType(ReportPartyCell)).length ~/ 2;

  testWidgets('first page matches the reference', (tester) async {
    await pumpPage(tester);

    expect(find.text('Showing 1–12 of 29'), findsOneWidget);
    expect(find.text('Sachin Paul'), findsOneWidget);
    expect(find.text('NR'), findsOneWidget);
    expect(find.text(AppStrings.abusiveLanguage), findsOneWidget);
    expect(rows(tester), 12);
  });

  testWidgets('pagination shows the remaining reports', (tester) async {
    await pumpPage(tester);

    await tester.tap(
      find.descendant(of: find.byType(AppPagination), matching: find.text('3')),
    );
    await tester.pump();

    expect(find.text('Showing 25–29 of 29'), findsOneWidget);
    expect(rows(tester), 5);
  });

  testWidgets('date filter menu lists the ranges', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text(AppStrings.filters));
    await tester.pumpAndSettle();
    for (final label in [
      AppStrings.yesterday,
      AppStrings.last7Days,
      AppStrings.last30Days,
      AppStrings.customDateRange,
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.tap(find.text(AppStrings.yesterday));
    await tester.pumpAndSettle();

    expect(rows(tester), 4);
    expect(find.text(AppStrings.yesterday), findsOneWidget);
  });

  testWidgets('report type filter keeps matching reports', (tester) async {
    await pumpPage(tester);
    await choose(tester, AppStrings.allReportTypes, AppStrings.harassment);

    expect(find.text(AppStrings.fakeProfile), findsNothing);
    expect(find.text(AppStrings.harassment), findsWidgets);
  });

  testWidgets('reporter filter keeps reports made by hosts', (tester) async {
    await pumpPage(tester);
    await choose(tester, AppStrings.all, AppStrings.hostRole);

    expect(find.text('Aishu'), findsOneWidget);
    expect(find.text('Abhijith S'), findsNothing);
  });

  testWidgets('search matches either party', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'midhun');
    await tester.pump();
    expect(find.text('Ananya'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nobody');
    await tester.pump();
    expect(find.text(AppStrings.noReportsFound), findsOneWidget);
  });

  testWidgets('sidebar opens the reports page', (tester) async {
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

    await tester.tap(find.text(AppStrings.reports));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.allReportTypes), findsOneWidget);
  });

  for (final width in [1024.0, 768.0, 390.0]) {
    testWidgets('no overflow at $width', (tester) async {
      await pumpPage(tester, Size(width, 900));
      expect(tester.takeException(), isNull);
    });
  }
}
