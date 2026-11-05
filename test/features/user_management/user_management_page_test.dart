import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_pagination.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/pages/user_management_page.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_management_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/widgets/user_action_button.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, [
    Size size = const Size(1728, 1116),
  ]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const UserManagementPage()),
    );
  }

  testWidgets('first page matches the reference', (tester) async {
    await pumpPage(tester);

    expect(find.text('Arjun Nair'), findsOneWidget);
    expect(find.text('Kiran Babu'), findsOneWidget);
    expect(find.text('Showing 1–12 of 44'), findsOneWidget);
    expect(find.text('…'), findsOneWidget);
    expect(find.text('Test User 13'), findsNothing);
    expect(find.text(AppStrings.noActions), findsNWidgets(2));
  });

  testWidgets('pagination moves to the next page', (tester) async {
    await pumpPage(tester);

    await tester.tap(
      find.descendant(of: find.byType(AppPagination), matching: find.text('2')),
    );
    await tester.pump();

    expect(find.text('Arjun Nair'), findsNothing);
    expect(find.text('Test User 13'), findsOneWidget);
    expect(find.text('Showing 13–24 of 44'), findsOneWidget);
  });

  testWidgets('filter menu shows all options and filters the table', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.text(AppStrings.allUsers));
    await tester.pumpAndSettle();
    for (final label in [
      AppStrings.newUsers,
      AppStrings.blockedUsers,
      AppStrings.deletedByAdminFilter,
      AppStrings.deletedByUserFilter,
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.tap(find.text(AppStrings.blockedUsers));
    await tester.pumpAndSettle();

    expect(find.text('Akhil Kumar'), findsOneWidget);
    expect(find.text('Arjun Nair'), findsNothing);
    expect(find.text('Showing 1–1 of 1'), findsOneWidget);
  });

  testWidgets('search matches phone numbers with or without spaces', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), '7861387');
    await tester.pump();

    expect(find.text('Arjun Nair'), findsOneWidget);
    expect(find.text('Rahul Menon'), findsNothing);
  });

  testWidgets('search with no match shows the empty state', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'nobody');
    await tester.pump();

    expect(find.text(AppStrings.noUsersFound), findsOneWidget);
  });

  Future<void> chooseAction(WidgetTester tester, String label) async {
    await tester.tap(find.byType(UserActionButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('delete asks for confirmation before removing the actions', (
    tester,
  ) async {
    await pumpPage(tester);
    await chooseAction(tester, AppStrings.delete);

    expect(find.text("Delete Arjun Nair's account?"), findsOneWidget);
    expect(find.text(AppStrings.noActions), findsNWidgets(2));

    await tester.tap(find.text(AppStrings.deleteAccountAction));
    await tester.pumpAndSettle();

    expect(find.text("Delete Arjun Nair's account?"), findsNothing);
    expect(find.text(AppStrings.deletedByAdmin), findsNWidgets(2));
    expect(find.text(AppStrings.noActions), findsNWidgets(3));
  });

  testWidgets('block asks for confirmation before blocking', (tester) async {
    await pumpPage(tester);
    await chooseAction(tester, AppStrings.block);

    expect(find.text('Block Arjun Nair?'), findsOneWidget);
    expect(find.text(AppStrings.blockUserMessage), findsOneWidget);
    expect(find.text(AppStrings.blocked), findsOneWidget);

    await tester.tap(find.text(AppStrings.blockUserAction));
    await tester.pumpAndSettle();

    expect(find.text('Block Arjun Nair?'), findsNothing);
    expect(find.text(AppStrings.blocked), findsNWidgets(2));
  });

  testWidgets('cancel and tapping outside leave the user unchanged', (
    tester,
  ) async {
    await pumpPage(tester);

    await chooseAction(tester, AppStrings.delete);
    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.deleteAccountAction), findsNothing);
    expect(find.text(AppStrings.noActions), findsNWidgets(2));

    await chooseAction(tester, AppStrings.block);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.blockUserAction), findsNothing);
    expect(find.text(AppStrings.blocked), findsOneWidget);
  });

  testWidgets('confirm dialog fits a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(
            child: AppConfirmDialog(
              icon: Icons.delete_outline_rounded,
              title: "Delete Abhijith Krishnamurthy's account?",
              message: TextSpan(text: AppStrings.blockUserMessage),
              confirmLabel: AppStrings.deleteAccountAction,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text(AppStrings.deleteAccountAction), findsOneWidget);
  });

  testWidgets('tapping outside closes the menu without a change', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.byType(UserActionButton).first);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(800, 1000));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.edit), findsNothing);
    expect(find.text(AppStrings.noActions), findsNWidgets(2));
  });

  Future<void> openEditSheet(WidgetTester tester) async {
    await tester.tap(find.byType(UserActionButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.edit));
    await tester.pumpAndSettle();
  }

  testWidgets('edit sheet shows the selected user', (tester) async {
    await pumpPage(tester);
    await openEditSheet(tester);

    expect(find.text(AppStrings.editUserDetails), findsOneWidget);
    expect(find.text('ZU10231 · Created 01 Nov 2026'), findsOneWidget);
    expect(find.text(AppStrings.userIdCannotBeChanged), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Arjun Nair'), findsOneWidget);
    expect(find.widgetWithText(TextField, '+91 78613 87558'), findsOneWidget);
  });

  testWidgets('saving updates the row and shows the success dialog', (
    tester,
  ) async {
    await pumpPage(tester);
    await openEditSheet(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Arjun Nair'),
      'Maya Iyer',
    );
    await tester.pump();
    await tester.tap(find.text(AppStrings.saveChanges));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.editUserDetails), findsNothing);
    expect(find.text(AppStrings.userDetailsUpdated), findsOneWidget);
    expect(find.text("Maya Iyer's details have been saved."), findsOneWidget);

    await tester.tap(find.text(AppStrings.done));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.userDetailsUpdated), findsNothing);
    expect(find.text('Maya Iyer'), findsOneWidget);
    expect(find.text('MI'), findsOneWidget);
    expect(find.text('Arjun Nair'), findsNothing);
  });

  testWidgets('cancel and close discard changes', (tester) async {
    await pumpPage(tester);

    for (final dismiss in [
      find.text(AppStrings.cancel),
      find.byIcon(Icons.close_rounded),
    ]) {
      await openEditSheet(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Arjun Nair'),
        'Changed',
      );
      await tester.tap(dismiss);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.editUserDetails), findsNothing);
      expect(find.text(AppStrings.userDetailsUpdated), findsNothing);
      expect(find.text('Arjun Nair'), findsOneWidget);
    }
  });

  testWidgets('save is disabled while a field is blank', (tester) async {
    await pumpPage(tester);
    await openEditSheet(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Arjun Nair'), ' ');
    await tester.pump();
    await tester.tap(find.text(AppStrings.saveChanges));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.editUserDetails), findsOneWidget);
  });

  testWidgets('edit sheet and dialog fit a narrow screen', (tester) async {
    await pumpPage(tester, const Size(390, 600));
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(-800, 0),
    );
    await tester.pumpAndSettle();
    await openEditSheet(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(AppStrings.saveChanges));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.userDetailsUpdated), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('initials use the first and last word', () {
    expect(AdminUser.initialsFor('Arjun Nair'), 'AN');
    expect(AdminUser.initialsFor('  Maya   K  Iyer '), 'MI');
    expect(AdminUser.initialsFor('kiran'), 'K');
  });

  for (final size in const [Size(1024, 700), Size(768, 900), Size(390, 844)]) {
    testWidgets('no overflow at ${size.width}', (tester) async {
      await pumpPage(tester, size);
      expect(tester.takeException(), isNull);
    });
  }

  test('last page holds the remaining users', () {
    final cubit = UserManagementCubit();
    addTearDown(cubit.close);

    expect(cubit.state.totalPages, 4);
    cubit.goToPage(4);
    expect(cubit.state.pageUsers, hasLength(8));
  });

  testWidgets('sidebar navigates between dashboard and users', (tester) async {
    tester.view.physicalSize = const Size(1728, 1116);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        initialRoute: AppRoutes.userManagement,
        routes: AppRoutes.routes,
      ),
    );
    expect(find.byType(UserManagementPage), findsOneWidget);

    await tester.tap(find.text(AppStrings.dashboard));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.revenueSummary), findsOneWidget);

    await tester.tap(find.text(AppStrings.userManagement));
    await tester.pumpAndSettle();
    expect(find.byType(UserManagementPage), findsOneWidget);
  });
}
