import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';

class BannerPreview extends StatelessWidget {
  const BannerPreview({super.key, required this.banner});

  static const double _height = 182;
  static const double _iconSize = 28;
  static const double _loaderSize = 24;
  static const double _loaderStroke = 2.5;

  final BannerImage banner;

  Widget _placeholder(Widget child) {
    return Container(
      height: _height,
      color: AppColors.statTileBackground,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: banner.imageName,
      child: Image.network(
        banner.imageUrl,
        height: _height,
        fit: BoxFit.cover,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : _placeholder(
                SizedBox.square(
                  dimension: _loaderSize,
                  child: CircularProgressIndicator(
                    strokeWidth: _loaderStroke,
                    color: context.appColors.onPrimarySoft,
                  ),
                ),
              ),
        errorBuilder: (context, _, _) => _placeholder(
          Icon(
            Icons.broken_image_outlined,
            size: _iconSize,
            color: context.appColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
