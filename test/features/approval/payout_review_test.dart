import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_sidebar_submenu.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_underline_tabs.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_state.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/payout_request_sheet.dart';

void main() {
  Future<void> pumpPayouts(
    WidgetTester tester, [
    Size size = const Size(1728, 1116),
  ]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.approval,
      ),
    );
    await tester.tap(
      find.descendant(
        of: find.byType(AppUnderlineTabs<ApprovalTab>),
        matching: find.text(AppStrings.payoutReview),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sidebar sub-items switch tabs', (tester) async {
    tester.view.physicalSize = const Size(1728, 1116);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.approval,
      ),
    );
    Finder subItem(String label) => find.descendant(
      of: find.byType(AdminSidebarSubmenu),
      matching: find.text(label),
    );

    await tester.tap(subItem(AppStrings.payoutReview));
    await tester.pumpAndSettle();
    expect(find.text('Neena Thomas'), findsOneWidget);

    await tester.tap(subItem(AppStrings.hostRequests));
    await tester.pumpAndSettle();
    expect(find.text('Athira Mohan'), findsOneWidget);
  });

  Finder inSheet(String text) => find.descendant(
    of: find.byType(PayoutRequestSheet),
    matching: find.text(text),
  );

  Finder inDialog(String text) => find.descendant(
    of: find.byType(AppConfirmDialog),
    matching: find.text(text),
  );

  Future<void> openAnjali(WidgetTester tester) async {
    await tester.tap(find.text('Anjali'));
    await tester.pumpAndSettle();
  }

  testWidgets('payout tab lists the reference payouts', (tester) async {
    await pumpPayouts(tester);

    expect(find.text('Neena Thomas'), findsOneWidget);
    expect(find.text('Thiruvananthapuram Statue'), findsOneWidget);
    expect(find.text('HDFC0007671'), findsOneWidget);
    expect(find.text(AppStrings.pending), findsNWidgets(8));
    expect(find.text('8'), findsOneWidget);
    expect(find.text('Athira Mohan'), findsNothing);
  });

  testWidgets('review sheet shows host and bank details', (tester) async {
    await pumpPayouts(tester);
    await openAnjali(tester);

    expect(inSheet('PO802 · Submitted 03 Nov 2026'), findsOneWidget);
    expect(inSheet('Chennai, Tamil Nadu'), findsOneWidget);
    expect(inSheet('+91 64219 17834'), findsOneWidget);
    expect(inSheet(AppStrings.active), findsOneWidget);
    expect(inSheet('Coimbatore RS Puram'), findsOneWidget);
    expect(inSheet('ICIC0007941'), findsOneWidget);
    expect(
      find.textContaining('HOST BASIC INFO', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('accept confirms and marks the payout accepted', (tester) async {
    await pumpPayouts(tester);
    await openAnjali(tester);

    await tester.tap(inSheet(AppStrings.accept));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.acceptPayoutTitle), findsOneWidget);
    expect(
      find.text(AppStrings.acceptPayoutMessage('Anjali', '6154')),
      findsOneWidget,
    );

    await tester.tap(inDialog(AppStrings.accept));
    await tester.pumpAndSettle();
    expect(find.byType(PayoutRequestSheet), findsNothing);
    expect(find.text(AppStrings.accepted), findsOneWidget);
    expect(find.text(AppStrings.view), findsOneWidget);
    expect(find.text('7'), findsNWidgets(2));
  });

  testWidgets('reject confirms and marks the payout rejected', (tester) async {
    await pumpPayouts(tester);
    await openAnjali(tester);

    await tester.tap(inSheet(AppStrings.reject));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.rejectPayoutTitle), findsOneWidget);
    await tester.tap(inDialog(AppStrings.reject));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.rejected), findsOneWidget);
  });

  testWidgets('view host opens host details', (tester) async {
    await pumpPayouts(tester);
    await openAnjali(tester);

    await tester.tap(inSheet(AppStrings.viewHost));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.backToHosts), findsOneWidget);
    expect(find.text('Anjali Menon'), findsWidgets);
  });

  for (final width in [1024.0, 768.0, 390.0]) {
    testWidgets('payout tab and sheet fit at $width', (tester) async {
      await pumpPayouts(tester, Size(width, 900));
      expect(tester.takeException(), isNull);
      await openAnjali(tester);
      expect(tester.takeException(), isNull);
    });
  }
}
