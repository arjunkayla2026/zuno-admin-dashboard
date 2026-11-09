import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_sidebar_submenu.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/pages/approval_page.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/host_request_sheet.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, [
    Size size = const Size(1728, 1116),
  ]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const ApprovalPage()),
    );
  }

  Finder inSheet(String text) => find.descendant(
    of: find.byType(HostRequestSheet),
    matching: find.text(text),
  );

  Future<void> openFirstRequest(WidgetTester tester) async {
    await tester.tap(find.text(AppStrings.review).first);
    await tester.pumpAndSettle();
  }

  testWidgets('lists the host requests from the reference', (tester) async {
    await pumpPage(tester);

    expect(find.text('Athira Mohan'), findsOneWidget);
    expect(find.text('Sandra Thomas'), findsOneWidget);
    expect(find.text('+91 86453 81621'), findsOneWidget);
    expect(find.text('Malayalam, Hindi, English'), findsOneWidget);
    expect(find.text(AppStrings.pending), findsNWidgets(9));
    expect(find.text('9'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AdminSidebarSubmenu),
        matching: find.text(AppStrings.hostRequests),
      ),
      findsOneWidget,
    );
  });

  testWidgets('filters by date and search', (tester) async {
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
    expect(find.text(AppStrings.pending), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), 'nasrin');
    await tester.pump();
    expect(find.text('Fathima Nasrin'), findsOneWidget);
    expect(find.text('Athira Mohan'), findsNothing);
  });

  testWidgets('review sheet shows the request details', (tester) async {
    await pumpPage(tester);
    await openFirstRequest(tester);

    expect(inSheet('HR3301 · Submitted 03 Nov 2026'), findsOneWidget);
    expect(inSheet('Athira · Ernakulam'), findsOneWidget);
    expect(inSheet('24 Aug 1994'), findsOneWidget);
    expect(inSheet(AppStrings.aadhaarCardImage), findsOneWidget);
    expect(inSheet(AppStrings.selfieUpload), findsOneWidget);
    expect(inSheet('XXXX XXXX 7152'), findsOneWidget);
  });

  Finder inDialog(String text) => find.descendant(
    of: find.byType(AppConfirmDialog),
    matching: find.text(text),
  );

  testWidgets('approve confirms, then shows the success dialog', (
    tester,
  ) async {
    await pumpPage(tester);
    await openFirstRequest(tester);

    await tester.tap(find.text(AppStrings.approve));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.approveRequestTitle), findsOneWidget);
    expect(
      find.text(AppStrings.approveRequestMessage('Athira Mohan')),
      findsOneWidget,
    );

    await tester.tap(inDialog(AppStrings.approve));
    await tester.pumpAndSettle();
    expect(find.byType(HostRequestSheet), findsNothing);
    expect(find.text(AppStrings.hostRequestApproved), findsOneWidget);
    expect(
      find.text('Status for Athira Mohan is now Approved.'),
      findsOneWidget,
    );

    await tester.tap(find.text(AppStrings.done));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.approved), findsOneWidget);
    expect(find.text(AppStrings.pending), findsNWidgets(8));
    expect(find.text(AppStrings.view), findsOneWidget);
    expect(find.text('8'), findsNWidgets(2));
  });

  testWidgets('cancelling approve keeps the request pending', (tester) async {
    await pumpPage(tester);
    await openFirstRequest(tester);

    await tester.tap(find.text(AppStrings.approve));
    await tester.pumpAndSettle();
    await tester.tap(inDialog(AppStrings.cancel));
    await tester.pumpAndSettle();

    expect(find.byType(HostRequestSheet), findsOneWidget);
    expect(find.text(AppStrings.approved), findsNothing);
  });

  testWidgets('reject asks for confirmation', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text(AppStrings.review).at(1));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.reject));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.rejectRequestTitle), findsOneWidget);
    expect(
      find.text("Fathima Nasrin's request to become a host will be rejected."),
      findsOneWidget,
    );

    await tester.tap(inDialog(AppStrings.reject));
    await tester.pumpAndSettle();
    expect(find.byType(HostRequestSheet), findsNothing);
    expect(find.text(AppStrings.hostRequestApproved), findsNothing);
    expect(find.text(AppStrings.rejected), findsOneWidget);
    expect(find.text(AppStrings.view), findsOneWidget);
  });

  testWidgets('edit saves changes back to the table', (tester) async {
    await pumpPage(tester);
    await openFirstRequest(tester);

    await tester.tap(find.text(AppStrings.edit));
    await tester.pumpAndSettle();
    expect(inSheet(AppStrings.telugu), findsOneWidget);

    final fields = find.descendant(
      of: find.byType(HostRequestSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(4), 'Kochi');
    await tester.tap(inSheet(AppStrings.telugu));
    await tester.pump();
    await tester.tap(find.text(AppStrings.saveChanges));
    await tester.pumpAndSettle();

    expect(inSheet('Athira · Kochi'), findsOneWidget);
    expect(inSheet(AppStrings.approve), findsOneWidget);

    await tester.tap(find.byTooltip(AppStrings.close));
    await tester.pumpAndSettle();
    expect(find.text('Kochi'), findsOneWidget);
    expect(find.text('English, Malayalam, Hindi, Telugu'), findsOneWidget);
  });

  testWidgets('sidebar opens the approval page', (tester) async {
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

    await tester.tap(find.text(AppStrings.approval));
    await tester.pumpAndSettle();
    expect(find.text('Athira Mohan'), findsOneWidget);
  });

  for (final width in [1024.0, 768.0, 390.0]) {
    testWidgets('no overflow at $width', (tester) async {
      await pumpPage(tester, Size(width, 900));
      expect(tester.takeException(), isNull);
    });

    testWidgets('sheet fits at $width', (tester) async {
      await pumpPage(tester, Size(width, 900));
      await tester.tap(find.text('Athira Mohan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.edit));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
