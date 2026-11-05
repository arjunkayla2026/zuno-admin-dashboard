import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/main.dart';

void main() {
  void setScreen(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('desktop shows the brand panel and the form', (tester) async {
    setScreen(tester, const Size(1728, 1116));
    await tester.pumpWidget(const MyApp());

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.welcomeBack), findsOneWidget);
    expect(find.text(AppStrings.signInSecurely), findsOneWidget);
  });

  testWidgets('narrow screens show only the form', (tester) async {
    setScreen(tester, const Size(390, 844));
    await tester.pumpWidget(const MyApp());

    expect(find.text(AppStrings.appName), findsNothing);
    expect(find.text(AppStrings.welcomeBack), findsOneWidget);
  });

  testWidgets('small desktop windows do not overflow', (tester) async {
    setScreen(tester, const Size(1024, 400));
    await tester.pumpWidget(const MyApp());

    expect(tester.takeException(), isNull);
  });

  testWidgets('Show toggles password visibility', (tester) async {
    setScreen(tester, const Size(1728, 1116));
    await tester.pumpWidget(const MyApp());

    TextField passwordField() =>
        tester.widget<TextField>(find.byType(TextField).last);

    expect(passwordField().obscureText, isTrue);
    await tester.tap(find.text(AppStrings.show));
    await tester.pump();
    expect(passwordField().obscureText, isFalse);
    expect(find.text(AppStrings.hide), findsOneWidget);
  });

  testWidgets('Sign in shows the error banner and keeps the entered email', (
    tester,
  ) async {
    setScreen(tester, const Size(1728, 1116));
    await tester.pumpWidget(const MyApp());
    expect(find.text(AppStrings.loginFailed), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'admin@test.app');
    await tester.tap(find.text(AppStrings.signInSecurely));
    await tester.pump();

    expect(find.text(AppStrings.loginFailed), findsOneWidget);
    expect(find.text('admin@test.app'), findsOneWidget);
  });

  testWidgets('error banner does not overflow on a narrow screen', (
    tester,
  ) async {
    setScreen(tester, const Size(320, 480));
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text(AppStrings.signInSecurely));
    await tester.pump();

    expect(find.text(AppStrings.loginFailed), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
