import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class AppDocumentImage extends StatelessWidget {
  const AppDocumentImage({
    super.key,
    required this.imageUrl,
    required this.placeholder,
    this.fit = BoxFit.cover,
  });

  static const double _loaderSize = 22;
  static const double _loaderStroke = 2;

  final String? imageUrl;
  final Widget placeholder;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) return placeholder;

    return ColoredBox(
      color: context.appColors.uploadBackground,
      child: Image.network(
        url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: SizedBox.square(
              dimension: _loaderSize,
              child: CircularProgressIndicator(
                strokeWidth: _loaderStroke,
                color: context.appColors.onPrimarySoft,
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}
