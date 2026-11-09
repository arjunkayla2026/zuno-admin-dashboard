import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_sidebar_submenu.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/pages/payment_page.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/pending_withdrawals_table.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/success_withdrawals_table.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_details_sheet.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_overview_card.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, [
    Size size = const Size(1728, 1116),
  ]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const PaymentPage()),
    );
  }

  Finder inOverview(String text) => find.descendant(
    of: find.byType(WithdrawalOverviewCard),
    matching: find.textContaining(text, findRichText: true),
  );

  Future<void> openPendingTab(WidgetTester tester) async {
    await tester.tap(find.text(AppStrings.pendingTab).first);
    await tester.pumpAndSettle();
  }

  testWidgets('shows the upcoming withdrawal overview totals', (tester) async {
    await pumpPage(tester);

    expect(
      find.text('13 hosts waiting · minimum withdrawal ₹300'),
      findsOneWidget,
    );
    expect(inOverview('₹90,114'), findsOneWidget);
    expect(inOverview('6,695'), findsOneWidget);
    expect(inOverview('₹1,260'), findsOneWidget);
    expect(inOverview('₹91,374'), findsNWidgets(2));
  });

  testWidgets('lists withdrawals with paging and sidebar sub-item', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('Showing 1–10 of 43'), findsOneWidget);
    expect(find.text('WD55102'), findsOneWidget);
    expect(find.text(AppStrings.view), findsNWidgets(10));
    expect(
      find.descendant(
        of: find.byType(AdminSidebarSubmenu),
        matching: find.text(AppStrings.withdrawalList),
      ),
      findsOneWidget,
    );
  });

  testWidgets('search filters by withdraw ID', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField).first, 'WD55107');
    await tester.pumpAndSettle();

    expect(find.text('Swathy'), findsOneWidget);
    expect(find.text(AppStrings.view), findsOneWidget);
  });

  testWidgets('pending tab shows bank details for all pending rows', (
    tester,
  ) async {
    await pumpPage(tester);
    await openPendingTab(tester);

    expect(find.byType(PendingWithdrawalsTable), findsOneWidget);
    expect(find.text(AppStrings.withdraw), findsNWidgets(13));
    expect(find.text('Bengaluru Indiranagar'), findsNWidgets(2));
    expect(find.text('UTIB0003759'), findsOneWidget);
  });

  testWidgets('withdrawal details sheet shows earnings and bank account', (
    tester,
  ) async {
    await pumpPage(tester);
    await openPendingTab(tester);

    await tester.tap(find.text(AppStrings.withdraw).first);
    await tester.pumpAndSettle();

    final sheet = find.byType(WithdrawalDetailsSheet);
    Finder inSheet(String text) =>
        find.descendant(of: sheet, matching: find.text(text));

    expect(inSheet(AppStrings.withdrawalDetails), findsOneWidget);
    expect(inSheet('WD55100 · Pending'), findsOneWidget);
    expect(inSheet('ZH10290 · +91 89822 97632'), findsOneWidget);
    expect(inSheet('03 Nov 2026'), findsOneWidget);
    expect(inSheet('453 min'), findsOneWidget);
    expect(inSheet('₹120'), findsOneWidget);
    expect(inSheet('₹5,556'), findsNWidgets(2));
    expect(inSheet('Nandana Suresh'), findsOneWidget);
  });

  testWidgets('review applies TDS and completes the withdrawal', (
    tester,
  ) async {
    await pumpPage(tester);
    await openPendingTab(tester);

    await tester.tap(find.text(AppStrings.withdraw).first);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(WithdrawalDetailsSheet),
        matching: find.text(AppStrings.withdraw),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.reviewWithdrawalTitle), findsOneWidget);
    expect(find.text('– ₹111.12', findRichText: true), findsOneWidget);
    expect(find.text('₹5,444.88', findRichText: true), findsOneWidget);

    await tester.tap(find.text(AppStrings.confirmWithdrawal));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.withdrawalCompleted), findsOneWidget);
    expect(
      find.textContaining(
        '₹5,444.88 has been sent to Nandana',
        findRichText: true,
      ),
      findsOneWidget,
    );

    await tester.tap(find.text(AppStrings.done));
    await tester.pumpAndSettle();

    expect(find.byType(WithdrawalDetailsSheet), findsNothing);
    expect(find.text(AppStrings.withdraw), findsNWidgets(12));
    expect(
      find.text('12 hosts waiting · minimum withdrawal ₹300'),
      findsOneWidget,
    );
  });

  testWidgets('success tab lists paid withdrawals with TDS', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text(AppStrings.successTab).first);
    await tester.pumpAndSettle();

    expect(find.byType(SuccessWithdrawalsTable), findsOneWidget);
    expect(find.text('Showing 1–10 of 30'), findsOneWidget);
    expect(find.text('30 Oct 2026'), findsOneWidget);
    expect(find.text('+91 62409 33178'), findsOneWidget);
    expect(find.text('1,089 min'), findsOneWidget);
    expect(find.text('₹261.36'), findsOneWidget);
    expect(find.text('₹12,806.64'), findsOneWidget);
    expect(find.text('₹135.6'), findsOneWidget);
    expect(find.text('₹6,644.4'), findsOneWidget);
    expect(find.text('2%'), findsNWidgets(10));
  });

  testWidgets('export shows the generated withdrawal sheet', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text(AppStrings.successTab).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.exportWithdrawalSheet));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.exportComplete), findsOneWidget);
    expect(find.text('30 withdrawals were exported.'), findsOneWidget);
    expect(
      find.text('withdrawal-sheet-success-04-Nov-2026.xlsx'),
      findsOneWidget,
    );
    expect(find.text('Withdrawal sheet · 30 rows'), findsOneWidget);
    expect(find.text(AppStrings.ready), findsOneWidget);

    await tester.tap(find.text(AppStrings.done));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.exportComplete), findsNothing);
  });

  testWidgets('fits a mobile width without overflow', (tester) async {
    await pumpPage(tester, const Size(390, 844));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
