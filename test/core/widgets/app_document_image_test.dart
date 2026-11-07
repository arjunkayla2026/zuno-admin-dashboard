import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/widgets/documents/app_document_image.dart';

void main() {
  const placeholder = Text('placeholder');

  Future<void> pump(WidgetTester tester, String? url) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: SizedBox(
          width: 200,
          height: 140,
          child: AppDocumentImage(imageUrl: url, placeholder: placeholder),
        ),
      ),
    );
  }

  testWidgets('shows the placeholder when there is no image', (tester) async {
    await pump(tester, null);

    expect(find.text('placeholder'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('loads the image when a url is given', (tester) async {
    await pump(tester, 'https://example.com/aadhaar.jpg');

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('falls back to the placeholder if the image fails', (
    tester,
  ) async {
    await pump(tester, 'https://example.com/aadhaar.jpg');
    await tester.pumpAndSettle();

    expect(find.text('placeholder'), findsOneWidget);
  });
}
