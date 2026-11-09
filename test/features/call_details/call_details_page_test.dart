import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/features/call_details/presentation/pages/call_details_page.dart';
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
      MaterialApp(theme: AppTheme.light, home: const CallDetailsPage()),
    );
  }

  testWidgets('shows the reference call', (tester) async {
    await pumpPage(tester);

    expect(find.text(AppStrings.videoCallTitle), findsOneWidget);
    expect(find.text(AppStrings.completed), findsNWidgets(2));
    expect(
      find.textContaining('CL784520', findRichText: true),
      findsNWidgets(2),
    );
    expect(find.text('User · ZU10231'), findsOneWidget);
    expect(find.text('Host · ZH10290'), findsOneWidget);
    expect(find.text('03:37:53 PM'), findsOneWidget);
    expect(find.text('03:38:12 PM'), findsOneWidget);
    expect(find.text('03:40:27 PM'), findsOneWidget);
    expect(find.text('2m 15s'), findsOneWidget);
    expect(find.text('270 coins'), findsOneWidget);
    expect(find.text('₹135'), findsOneWidget);
    expect(find.text('₹24/min'), findsOneWidget);
    expect(find.text('₹36/min'), findsOneWidget);
    expect(find.text('₹54'), findsOneWidget);
    expect(find.text('₹81'), findsOneWidget);
    expect(find.text('SES-4b28b44c'), findsOneWidget);
  });

  testWidgets('tapping a call row opens its details', (tester) async {
    tester.view.physicalSize = const Size(1728, 1116);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.calls,
      ),
    );

    await tester.tap(find.text('Tarun Singh'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.backToCalls), findsOneWidget);
    expect(find.text('13m 34s'), findsOneWidget);
    expect(find.text('1,628 coins'), findsOneWidget);

    await tester.tap(find.text(AppStrings.backToCalls));
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
