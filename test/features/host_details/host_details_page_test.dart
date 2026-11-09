import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_close_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_profile_menu_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_wallet_adjustment_dialog.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/pages/host_details_page.dart';
import 'package:zuno_admin_dashboard/core/widgets/documents/app_document_preview_dialog.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/edit_host_sheet.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, [
    Size size = const Size(1728, 1116),
  ]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const HostDetailsPage()),
    );
  }

  testWidgets('shows the reference profile, stats and call history', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('Nandana Suresh'), findsWidgets);
    expect(find.text(AppStrings.offline), findsOneWidget);
    expect(find.text(AppStrings.hostUploadedDocuments), findsOneWidget);
    expect(find.text(AppStrings.selfie), findsOneWidget);
    expect(find.text('₹32,949'), findsOneWidget);
    expect(find.text('₹2,818'), findsNWidgets(2));
    expect(find.text(AppStrings.callsCount(5)), findsOneWidget);
    expect(find.text('Sanjay Rao'), findsOneWidget);
    expect(find.text(AppStrings.showingOf(5, 5)), findsOneWidget);
  });

  testWidgets('type filter narrows the call list', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text(AppStrings.audio).first);
    await tester.pump();

    expect(find.text(AppStrings.callsCount(2)), findsOneWidget);
    expect(find.text('Rahul Menon'), findsNothing);
  });

  testWidgets('withdrawal tab lists the withdrawals', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text(AppStrings.withdrawalHistory));
    await tester.pump();

    expect(find.text('Sanjay Rao'), findsNothing);
    expect(find.text('WD55100'), findsOneWidget);
    expect(find.text('₹5,556'), findsOneWidget);
    expect(find.text(AppStrings.pending), findsOneWidget);
    expect(find.text(AppStrings.success), findsOneWidget);
    expect(find.text(AppStrings.emptyValue), findsOneWidget);
  });

  testWidgets('wallet tab filters credits and debits', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text(AppStrings.walletHistory));
    await tester.pump();
    expect(find.text('+₹215'), findsOneWidget);
    expect(find.text('−₹50'), findsOneWidget);
    expect(find.text(AppStrings.success), findsNWidgets(10));

    await tester.tap(find.text(AppStrings.debit).first);
    await tester.pump();
    expect(find.text('+₹215'), findsNothing);
    expect(find.text('−₹50'), findsOneWidget);
  });

  testWidgets('saved credit appears at the top of wallet history', (
    tester,
  ) async {
    await pumpPage(tester);
    await tester.tap(find.text(AppStrings.walletHistory));
    await tester.pump();

    await tester.tap(find.text(AppStrings.creditDebitWallet));
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(AppWalletAdjustmentDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), '75');
    await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.save));
    await tester.pumpAndSettle();

    expect(find.text('+₹75'), findsOneWidget);
    expect(find.text(AppStrings.adminCredit), findsNWidgets(3));
  });

  testWidgets('blocking from the profile menu updates the host', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.byType(AppProfileMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.deleteAccountAction));
    await tester.pumpAndSettle();

    expect(find.byType(AppProfileMenuButton), findsNothing);
  });

  Future<void> openWalletDialog(WidgetTester tester) async {
    await tester.tap(find.text(AppStrings.creditDebitWallet));
    await tester.pumpAndSettle();
  }

  Finder dialogField(int index) => find
      .descendant(
        of: find.byType(AppWalletAdjustmentDialog),
        matching: find.byType(TextField),
      )
      .at(index);

  Finder saveButton() => find.widgetWithText(ElevatedButton, AppStrings.save);

  testWidgets('credit adds to the wallet and admin credit total', (
    tester,
  ) async {
    await pumpPage(tester);
    await openWalletDialog(tester);

    expect(find.text(AppStrings.credit), findsOneWidget);
    expect(find.text(AppStrings.debit), findsOneWidget);
    expect(tester.widget<ElevatedButton>(saveButton()).onPressed, isNotNull);

    await tester.tap(saveButton());
    await tester.pump();
    expect(find.text(AppStrings.enterAmount), findsOneWidget);
    expect(find.byType(AppWalletAdjustmentDialog), findsOneWidget);

    await tester.enterText(dialogField(0), '200');
    await tester.enterText(dialogField(1), 'Bonus');
    await tester.pump();
    await tester.tap(saveButton());
    await tester.pumpAndSettle();

    expect(find.byType(AppWalletAdjustmentDialog), findsNothing);
    expect(find.text('₹3,018'), findsOneWidget);
    expect(find.text('₹300'), findsOneWidget);
  });

  testWidgets('debit cannot exceed the wallet balance', (tester) async {
    await pumpPage(tester);
    await openWalletDialog(tester);

    await tester.tap(find.text(AppStrings.debit));
    await tester.pump();
    await tester.enterText(dialogField(0), '5000');
    await tester.pump();

    expect(find.text(AppStrings.debitExceedsBalance('₹2,818')), findsOneWidget);
    await tester.tap(saveButton());
    await tester.pump();
    expect(find.byType(AppWalletAdjustmentDialog), findsOneWidget);

    await tester.enterText(dialogField(0), '18');
    await tester.pump();
    await tester.tap(saveButton());
    await tester.pumpAndSettle();

    expect(find.text('₹2,800'), findsOneWidget);
    expect(find.text('₹18'), findsOneWidget);
  });

  testWidgets('cancel leaves the wallet unchanged', (tester) async {
    await pumpPage(tester);
    await openWalletDialog(tester);

    await tester.enterText(dialogField(0), '200');
    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();

    expect(find.byType(AppWalletAdjustmentDialog), findsNothing);
    expect(find.text('₹2,818'), findsNWidgets(2));
  });

  testWidgets('tapping a document opens its preview', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text(AppStrings.aadhaarCard));
    await tester.pumpAndSettle();
    expect(find.text('Aadhaar card · Nandana Suresh'), findsOneWidget);
    expect(find.byType(AppDocumentPreviewDialog), findsOneWidget);

    await tester.tap(find.byType(AppCloseButton));
    await tester.pumpAndSettle();
    expect(find.byType(AppDocumentPreviewDialog), findsNothing);

    await tester.tap(find.text(AppStrings.selfie));
    await tester.pumpAndSettle();
    expect(find.text('Selfie · Nandana Suresh'), findsOneWidget);
  });

  Future<void> openEditSheet(WidgetTester tester) async {
    await tester.tap(find.byType(AppProfileMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.edit));
    await tester.pumpAndSettle();
  }

  testWidgets('edit sheet shows the full host profile', (tester) async {
    await pumpPage(tester);
    await openEditSheet(tester);

    final sheet = find.byType(EditHostSheet);
    Finder inSheet(String text) =>
        find.descendant(of: sheet, matching: find.text(text));

    expect(inSheet('ZH10290 · Created 09 Aug 2026'), findsOneWidget);
    expect(inSheet('22 Dec 2000'), findsOneWidget);
    expect(inSheet('Mysuru'), findsOneWidget);
    expect(inSheet('Karnataka'), findsOneWidget);
    expect(inSheet(AppStrings.female), findsOneWidget);
    expect(inSheet(AppStrings.speakLanguagesField), findsOneWidget);
    expect(inSheet(AppStrings.telugu), findsOneWidget);
  });

  testWidgets('edit sheet saves profile changes', (tester) async {
    await pumpPage(tester);
    await openEditSheet(tester);

    final fields = find.descendant(
      of: find.byType(EditHostSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'Nandana S');
    await tester.enterText(fields.at(1), 'Nandu');
    await tester.tap(
      find.descendant(
        of: find.byType(EditHostSheet),
        matching: find.text(AppStrings.telugu),
      ),
    );
    await tester.pump();
    await tester.tap(find.text(AppStrings.saveChanges));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.done));
    await tester.pumpAndSettle();

    expect(find.text('Nandu'), findsOneWidget);
    expect(find.text('Nandana S'), findsNWidgets(2));
  });

  testWidgets('delete asks for confirmation', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byType(AppProfileMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.delete));
    await tester.pumpAndSettle();

    expect(find.text("Delete Nandana's account?"), findsOneWidget);
    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();
    expect(find.byType(AppProfileMenuButton), findsOneWidget);
  });

  for (final width in [1024.0, 768.0, 390.0]) {
    testWidgets('no overflow at $width', (tester) async {
      await pumpPage(tester, Size(width, 900));
      expect(tester.takeException(), isNull);
    });

    testWidgets('wallet dialog fits at $width', (tester) async {
      await pumpPage(tester, Size(width, 900));
      await openWalletDialog(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('document preview fits at $width', (tester) async {
      await pumpPage(tester, Size(width, 900));
      await tester.tap(find.text(AppStrings.aadhaarCard));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('edit sheet fits at $width', (tester) async {
      await pumpPage(tester, Size(width, 900));
      await openEditSheet(tester);
      expect(tester.takeException(), isNull);
    });
  }
}
