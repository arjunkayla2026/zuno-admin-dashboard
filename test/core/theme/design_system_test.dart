import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

void main() {
  test('CSS #FDC90321 converts to ARGB with alpha first', () {
    const color = AppColors.submoduleSelectedBackground;
    expect(color.toARGB32(), 0x21FDC903);
    expect((color.a * 255).round(), 0x21);
  });

  test('line heights resolve to the specified pixel values', () {
    double px(TextStyle style) => style.fontSize! * style.height!;
    expect(px(AppTextStyles.pageTitle), closeTo(24, 0.001));
    expect(px(AppTextStyles.splashHeading), closeTo(51.52, 0.001));
    expect(px(AppTextStyles.bodyLarge), closeTo(25.6, 0.001));
  });

  test('both themes build', () {
    expect(AppTheme.light.scaffoldBackgroundColor, AppColors.background);
    expect(AppTheme.dark.brightness, Brightness.dark);
  });

  testWidgets('status lookup covers every status', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox();
          },
        ),
      ),
    );

    const expected = {
      AppStatus.active: (AppColors.activeBadge, AppColors.activeText),
      AppStatus.inactive: (AppColors.inactiveBadge, AppColors.inactiveText),
      AppStatus.isNew: (AppColors.newBadge, AppColors.newText),
      AppStatus.pending: (AppColors.pendingBadge, AppColors.pendingText),
      AppStatus.blocked: (AppColors.errorBadge, AppColors.errorText),
      AppStatus.error: (AppColors.errorBadge, AppColors.errorText),
    };

    expect(expected.length, AppStatus.values.length);
    expected.forEach((status, colors) {
      final result = AppUtils.statusColors(context, status);
      expect(result.background, colors.$1);
      expect(result.foreground, colors.$2);
    });
  });

  testWidgets('themed buttons lay out inside a Row', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Row(
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('Approve')),
              OutlinedButton(onPressed: () {}, child: const Text('Reject')),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
