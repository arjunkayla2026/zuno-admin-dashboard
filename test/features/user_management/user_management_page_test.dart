import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_pagination.dart';
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

  testWidgets('delete from the action menu removes the actions', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.byType(UserActionButton).first);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.edit), findsOneWidget);
    expect(find.text(AppStrings.block), findsOneWidget);

    await tester.tap(find.text(AppStrings.delete));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.deletedByAdmin), findsNWidgets(2));
    expect(find.text(AppStrings.noActions), findsNWidgets(3));
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
