import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/mock/user_details_mock_data.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/pages/user_details_page.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/mock/user_mock_data.dart';

void main() {
  Future<void> openDialog(
    WidgetTester tester, [
    Size size = const Size(1728, 1116),
  ]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const UserDetailsPage()),
    );
    await tester.ensureVisible(find.text(AppStrings.rechargeHistory));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.rechargeHistory));
    await tester.pump();
    await tester.ensureVisible(find.text(AppStrings.addRecharge));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.addRecharge));
    await tester.pumpAndSettle();
  }

  testWidgets('full flow updates the stats, table and counts', (tester) async {
    await openDialog(tester);

    expect(find.text(AppStrings.choosePackage), findsOneWidget);
    expect(find.text('Arjun Nair · ZU10231'), findsOneWidget);
    expect(find.text('2,500 coins · +400 Bonus'), findsOneWidget);
    expect(find.text('100 coins'), findsOneWidget);

    await tester.tap(find.text(AppStrings.continueAction));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.confirmRecharge), findsOneWidget);
    expect(find.text('₹199'), findsWidgets);
    expect(find.text('+50 Bonus'), findsOneWidget);
    expect(find.text('550'), findsWidgets);

    await tester.tap(find.text(AppStrings.addRechargeAction));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.rechargeAdded), findsOneWidget);
    expect(
      find.text("550 coins were added to Arjun Nair's wallet."),
      findsOneWidget,
    );

    await tester.tap(find.text(AppStrings.done));
    await tester.pumpAndSettle();

    expect(find.text('₹3,142'), findsOneWidget);
    expect(find.text('2,648'), findsOneWidget);
    expect(find.text('₹1,324'), findsOneWidget);
    expect(find.text('Showing 8 of 8'), findsOneWidget);
    expect(find.text(AppStrings.adminRecharge), findsNWidgets(4));
  });

  testWidgets('choosing another package uses its values', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('250 coins'));
    await tester.pump();
    await tester.tap(find.text(AppStrings.continueAction));
    await tester.pumpAndSettle();

    expect(find.text('₹99'), findsWidgets);
    expect(find.text(AppStrings.emptyValue), findsWidgets);
    expect(find.text('250'), findsNWidgets(2));

    await tester.tap(find.text(AppStrings.addRechargeAction));
    await tester.pumpAndSettle();

    expect(
      find.text("250 coins were added to Arjun Nair's wallet."),
      findsOneWidget,
    );
  });

  testWidgets('cancelling at either step changes nothing', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.choosePackage), findsNothing);
    expect(find.text('₹2,943'), findsOneWidget);

    await tester.tap(find.text(AppStrings.addRecharge));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.continueAction));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.confirmRecharge), findsNothing);
    expect(find.text(AppStrings.choosePackage), findsNothing);
    expect(find.text('₹2,943'), findsOneWidget);
    expect(find.text('Showing 7 of 7'), findsOneWidget);
  });

  testWidgets('dialogs fit a narrow screen', (tester) async {
    await openDialog(tester, const Size(390, 700));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(AppStrings.continueAction));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text(AppStrings.addRechargeAction), findsOneWidget);
  });

  test('cubit adds a recharge to the top with the current date and time', () {
    final cubit = UserDetailsCubit(
      user: UserMockData.users.first,
      clock: () => DateTime(2026, 11, 4, 10, 8),
    );
    addTearDown(cubit.close);

    cubit.addRecharge(UserDetailsMockData.packages[2]);

    final record = cubit.state.recharges.first;
    expect(record.date, DateTime(2026, 11, 4));
    expect(record.time, '10:08 AM');
    expect(record.amount, '₹199');
    expect(record.receivedCoins, '550');
    expect(record.orderId, matches(RegExp(r'^ADM-[A-Z0-9]{8}$')));
    expect(record.paymentId, isNull);
    expect(cubit.state.recharges, hasLength(8));
  });
}
