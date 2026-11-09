import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_sidebar_submenu.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_switch.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/pages/settings_page.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/admin_sheet.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/admins_table.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/maintenance_top_bar_badge.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/banner_preview.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/notification_audience_card.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, [
    Size size = const Size(1440, 900),
  ]) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const SettingsPage()),
    );
  }

  bool switchValue(WidgetTester tester) =>
      tester.widget<Switch>(find.byType(Switch)).value;

  testWidgets('shows maintenance mode off with the note', (tester) async {
    await pumpPage(tester);

    expect(find.text(AppStrings.maintenanceNote), findsOneWidget);
    expect(
      find.textContaining('Maintenance mode is off', findRichText: true),
      findsOneWidget,
    );
    expect(switchValue(tester), isFalse);
    expect(
      find.descendant(
        of: find.byType(AdminSidebarSubmenu),
        matching: find.text(AppStrings.maintenanceMode),
      ),
      findsOneWidget,
    );
  });

  testWidgets('turning on asks for confirmation', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byType(AppStatusSwitch));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.turnOnMaintenanceTitle), findsOneWidget);

    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();
    expect(switchValue(tester), isFalse);

    await tester.tap(find.byType(AppStatusSwitch));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.turnOn));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.maintenanceOnMessage), findsOneWidget);
    expect(find.byType(MaintenanceTopBarBadge), findsOneWidget);

    await tester.tap(find.text(AppStrings.done));
    await tester.pumpAndSettle();

    expect(switchValue(tester), isTrue);
    expect(
      find.textContaining('Maintenance mode is on.', findRichText: true),
      findsOneWidget,
    );
    expect(find.byType(MaintenanceTopBarBadge), findsOneWidget);
  });

  testWidgets('admin management lists admins with permissions', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text(AppStrings.adminManagement).first);
    await tester.pumpAndSettle();

    expect(find.text('4 admins'), findsOneWidget);
    expect(find.text(AppStrings.addAdmin), findsOneWidget);
    expect(find.text('divya@yellowcalling.app'), findsOneWidget);
    expect(find.text(AppStrings.superAdmin), findsWidgets);
    expect(find.text(AppStrings.financeAdmin), findsOneWidget);
    expect(find.text(AppStrings.allModules), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AdminsTable),
        matching: find.text(AppStrings.reports),
      ),
      findsNWidgets(2),
    );
    expect(find.text(AppStrings.edit), findsNWidgets(4));
  });

  Future<void> openAdminTab(WidgetTester tester) async {
    await tester.tap(find.text(AppStrings.adminManagement).first);
    await tester.pumpAndSettle();
  }

  Finder sheetField(int index) => find
      .descendant(of: find.byType(AdminSheet), matching: find.byType(TextField))
      .at(index);

  testWidgets('add admin validates and adds the new admin', (tester) async {
    await pumpPage(tester);
    await openAdminTab(tester);

    await tester.tap(find.text(AppStrings.addAdmin));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.addAdminSubtitle), findsOneWidget);
    expect(find.text(AppStrings.supportAdmin), findsWidgets);

    await tester.tap(find.text(AppStrings.saveAdmin));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.enterName), findsOneWidget);
    expect(find.text(AppStrings.enterValidEmail), findsOneWidget);
    expect(find.text(AppStrings.enterValidPhone), findsOneWidget);
    expect(find.text(AppStrings.chooseModule), findsOneWidget);

    await tester.enterText(sheetField(0), 'Anu Joseph');
    await tester.enterText(sheetField(1), 'anu@yellowcalling.app');
    await tester.enterText(sheetField(2), '+91 99887 76655');
    await tester.tap(
      find.descendant(
        of: find.byType(AdminSheet),
        matching: find.text(AppStrings.calls),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.saveAdmin));
    await tester.pumpAndSettle();

    expect(find.byType(AdminSheet), findsNothing);
    expect(find.text('5 admins'), findsOneWidget);
    expect(find.text('anu@yellowcalling.app'), findsOneWidget);
  });

  testWidgets('edit admin prefills and updates the row', (tester) async {
    await pumpPage(tester);
    await openAdminTab(tester);

    await tester.tap(find.text(AppStrings.edit).at(3));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.editAdmin), findsOneWidget);
    expect(
      tester.widget<TextField>(sheetField(0)).controller!.text,
      'Nisha Ramesh',
    );

    await tester.enterText(sheetField(0), 'Nisha R');
    await tester.tap(find.text(AppStrings.saveAdmin));
    await tester.pumpAndSettle();

    expect(find.text('Nisha R'), findsOneWidget);
    expect(find.text('4 admins'), findsOneWidget);
  });

  testWidgets('notification audience follows send to and languages', (
    tester,
  ) async {
    await pumpPage(tester);
    await tester.tap(find.text(AppStrings.notificationManagement).first);
    await tester.pumpAndSettle();

    final card = find.byType(NotificationAudienceCard);
    Finder inCard(String text) =>
        find.descendant(of: card, matching: find.text(text));

    expect(inCard('8,240'), findsOneWidget);
    expect(inCard('1,126'), findsOneWidget);
    expect(inCard('9,366'), findsOneWidget);

    await tester.tap(find.text(AppStrings.malayalam));
    await tester.pumpAndSettle();
    expect(inCard(AppStrings.hostsForLanguages('Malayalam')), findsOneWidget);
    expect(inCard('446'), findsOneWidget);
    expect(inCard('8,686'), findsOneWidget);

    await tester.tap(find.text(AppStrings.userAudience));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.hostMotherTongue), findsNothing);
    expect(inCard(AppStrings.hostsLabel), findsNothing);
    expect(inCard(AppStrings.usersLabel), findsOneWidget);

    await tester.tap(find.text(AppStrings.sendNotification));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.enterTitle), findsOneWidget);
    expect(find.text(AppStrings.enterMessage), findsOneWidget);

    await tester.tap(find.text(AppStrings.clear));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.enterTitle), findsNothing);
    expect(inCard('9,366'), findsOneWidget);
  });

  testWidgets('send confirms the audience and clears the form', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text(AppStrings.notificationManagement).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.hostAudience));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.malayalam));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.tamil));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Bonus packs');
    await tester.enterText(find.byType(TextField).last, 'Recharge today.');
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.sendNotification));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.sendNotificationTitle), findsOneWidget);
    expect(find.text('Malayalam, Tamil'), findsOneWidget);

    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.sendNotificationTitle), findsNothing);
    expect(find.text('Bonus packs'), findsOneWidget);

    await tester.tap(find.text(AppStrings.sendNotification));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.sendNow));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.sendNotificationTitle), findsNothing);
    expect(find.text('Bonus packs'), findsNothing);
  });

  Future<void> openBanners(WidgetTester tester, [Size? size]) async {
    await pumpPage(tester, size ?? const Size(1440, 900));
    await tester.tap(find.text(AppStrings.bannerImageManagement).first);
    await tester.pumpAndSettle();
  }

  testWidgets('banner tab lists the banners', (tester) async {
    await openBanners(tester);

    expect(find.byType(AppStatusSwitch), findsNothing);
    expect(find.text(AppStrings.bannersSummary(3)), findsOneWidget);
    expect(find.text(AppStrings.bannerName(3)), findsOneWidget);
    expect(find.text('Talk in your language'), findsOneWidget);
    final actionPill = find
        .ancestor(of: find.text('Explore'), matching: find.byType(Container))
        .first;
    expect(
      tester.getSize(actionPill).width,
      lessThan(tester.getSize(find.byType(BannerPreview).at(1)).width / 2),
    );
    expect(
      find.text(AppStrings.bannerMeta('languages.png', '26 Oct 2026')),
      findsOneWidget,
    );
  });

  testWidgets('delete asks first and renumbers the banners', (tester) async {
    await openBanners(tester);

    await tester.tap(find.text(AppStrings.delete).at(1));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.deleteBannerTitle), findsOneWidget);

    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.bannersSummary(3)), findsOneWidget);

    await tester.tap(find.text(AppStrings.delete).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.deleteBannerAction));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.bannersSummary(2)), findsOneWidget);
    expect(find.text('Talk in your language'), findsNothing);
    expect(find.text('Mega pack is here'), findsOneWidget);
    expect(find.text(AppStrings.bannerName(3)), findsNothing);
  });

  testWidgets('add banner needs an image first', (tester) async {
    await openBanners(tester);

    await tester.tap(find.text(AppStrings.addBanner));
    await tester.pumpAndSettle();

    ElevatedButton addButton() => tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text(AppStrings.addBannerAction),
        matching: find.bySubtype<ElevatedButton>(),
      ),
    );

    expect(addButton().onPressed, isNull);

    await tester.tap(find.text(AppStrings.bannerDropTitle));
    await tester.pumpAndSettle();
    expect(addButton().onPressed, isNotNull);

    await tester.tap(find.text(AppStrings.addBannerAction));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.bannersSummary(4)), findsOneWidget);
    expect(find.text(AppStrings.bannerName(4)), findsOneWidget);
  });

  testWidgets('banner tab and dialogs fit a mobile width', (tester) async {
    await openBanners(tester, const Size(390, 844));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(AppStrings.addBanner));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits a mobile width without overflow', (tester) async {
    await pumpPage(tester, const Size(390, 844));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
