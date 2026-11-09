import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';

void main() {
  Future<void> pumpTable(WidgetTester tester, {required bool alignEnd}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 300,
              child: AppDataTable(
                columns: [
                  const AppTableColumn('A', 300),
                  AppTableColumn('B', 200, alignEnd: alignEnd),
                ],
                rows: const [
                  [Text('a1'), Text('b1')],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final position = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pump();
  }

  testWidgets('right-aligned last column keeps a margin at the scroll end', (
    tester,
  ) async {
    await pumpTable(tester, alignEnd: true);

    expect(tester.getTopRight(find.text('b1')).dx, 280);
    expect(tester.getTopRight(find.text('B')).dx, 280);
  });

  testWidgets('left-aligned last column adds no end margin', (tester) async {
    await pumpTable(tester, alignEnd: false);

    expect(tester.getTopLeft(find.text('b1')).dx, 100);
  });
}
