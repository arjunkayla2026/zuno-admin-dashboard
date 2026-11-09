import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/pages/user_details_page.dart';

void main() {
  final menuButton = find.byIcon(Icons.more_vert_rounded);

  Future<void> pumpDetails(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1728, 1116);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const UserDetailsPage()),
    );
  }

  Future<void> choose(WidgetTester tester, String label) async {
    await tester.tap(menuButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('menu opens below the button with its right edge past it', (
    tester,
  ) async {
    await pumpDetails(tester);
    final buttonCenter = tester.getCenter(menuButton);

    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.edit), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SvgPicture &&
            widget.bytesLoader is SvgAssetLoader &&
            (widget.bytesLoader as SvgAssetLoader).assetName ==
                AppImages.editIcon,
      ),
      findsOneWidget,
    );
    expect(find.text(AppStrings.block), findsOneWidget);
    expect(find.text(AppStrings.delete), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(AppStrings.edit)).dy,
      greaterThan(buttonCenter.dy + 39),
    );
    expect(
      tester.getTopRight(find.text(AppStrings.edit)).dx,
      lessThan(buttonCenter.dx + 6),
    );
  });

  testWidgets('edit updates the profile card', (tester) async {
    await pumpDetails(tester);
    await choose(tester, AppStrings.edit);

    await tester.enterText(
      find.widgetWithText(TextField, 'Arjun Nair'),
      'Maya Iyer',
    );
    await tester.pump();
    await tester.tap(find.text(AppStrings.saveChanges));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.done));
    await tester.pumpAndSettle();

    expect(find.text('Maya Iyer'), findsOneWidget);
    expect(find.text('MI'), findsOneWidget);
    expect(find.text('Arjun Nair'), findsNothing);
  });

  testWidgets('block asks first, then updates the status badge', (
    tester,
  ) async {
    await pumpDetails(tester);
    await choose(tester, AppStrings.block);

    expect(find.text('Block Arjun Nair?'), findsOneWidget);
    expect(find.text(AppStrings.active), findsOneWidget);

    await tester.tap(find.text(AppStrings.blockUserAction));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.blocked), findsOneWidget);
    expect(find.text(AppStrings.active), findsNothing);
  });

  testWidgets('delete updates the badge and removes the menu', (tester) async {
    await pumpDetails(tester);
    await choose(tester, AppStrings.delete);
    await tester.tap(find.text(AppStrings.deleteAccountAction));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.deletedByAdmin), findsOneWidget);
    expect(menuButton, findsNothing);
  });

  testWidgets('cancel leaves the user unchanged', (tester) async {
    await pumpDetails(tester);
    await choose(tester, AppStrings.delete);
    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.active), findsOneWidget);
    expect(menuButton, findsOneWidget);
  });

  testWidgets(
    'changes made on details show in the user list after going back',
    (tester) async {
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
      await tester.tap(find.text('Rahul Menon'));
      await tester.pumpAndSettle();

      await choose(tester, AppStrings.delete);
      await tester.tap(find.text(AppStrings.deleteAccountAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.backToUsers));
      await tester.pumpAndSettle();

      expect(find.byType(UserDetailsPage), findsNothing);
      expect(find.text(AppStrings.noActions), findsNWidgets(3));
      expect(find.text(AppStrings.deletedByAdmin), findsNWidgets(2));
    },
  );
}
