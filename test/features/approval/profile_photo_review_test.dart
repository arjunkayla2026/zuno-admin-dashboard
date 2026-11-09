import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_underline_tabs.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/pages/approval_page.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_state.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/profile_photo_card.dart';

void main() {
  Future<void> pumpPhotos(
    WidgetTester tester, [
    Size size = const Size(1728, 1116),
  ]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const ApprovalPage()),
    );
    await tester.tap(
      find.descendant(
        of: find.byType(AppUnderlineTabs<ApprovalTab>),
        matching: find.text(AppStrings.profilePhotoReview),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder inDialog(String text) => find.descendant(
    of: find.byType(AppConfirmDialog),
    matching: find.text(text),
  );

  Finder cardButton(String host, String label) => find.descendant(
    of: find.ancestor(
      of: find.text(host),
      matching: find.byType(ProfilePhotoCard),
    ),
    matching: find.text(label),
  );

  testWidgets('shows a card for every pending photo', (tester) async {
    await pumpPhotos(tester);

    expect(find.byType(ProfilePhotoCard), findsNWidgets(7));
    expect(find.text('Meera Krishnan · Thiruvananthapuram'), findsOneWidget);
    expect(
      find.text('Malayalam, English · Submitted 03 Nov 2026'),
      findsOneWidget,
    );
    expect(find.text(AppStrings.pending), findsNWidgets(7));
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('accept confirms and updates the card', (tester) async {
    await pumpPhotos(tester);

    await tester.tap(cardButton('Meera', AppStrings.accept));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.acceptPhotoTitle), findsOneWidget);
    expect(
      find.text("The new photo will appear on Meera's profile."),
      findsOneWidget,
    );

    await tester.tap(inDialog(AppStrings.accept));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.accepted), findsOneWidget);
    expect(cardButton('Meera', AppStrings.accept), findsNothing);
    expect(find.text('6'), findsOneWidget);
  });

  testWidgets('reject confirms and updates the card', (tester) async {
    await pumpPhotos(tester);

    await tester.tap(cardButton('Neena', AppStrings.reject));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.rejectPhotoTitle), findsOneWidget);

    await tester.tap(inDialog(AppStrings.reject));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.rejected), findsOneWidget);
  });

  testWidgets('cancel keeps the photo pending', (tester) async {
    await pumpPhotos(tester);

    await tester.tap(cardButton('Kavya', AppStrings.accept));
    await tester.pumpAndSettle();
    await tester.tap(inDialog(AppStrings.cancel));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.pending), findsNWidgets(7));
  });

  testWidgets('search narrows the grid', (tester) async {
    await pumpPhotos(tester);

    await tester.enterText(find.byType(TextField), 'mysuru');
    await tester.pump();

    expect(find.byType(ProfilePhotoCard), findsNWidgets(2));
  });

  for (final width in [1024.0, 768.0, 390.0]) {
    testWidgets('grid fits at $width', (tester) async {
      await pumpPhotos(tester, Size(width, 900));
      expect(tester.takeException(), isNull);
    });
  }
}
