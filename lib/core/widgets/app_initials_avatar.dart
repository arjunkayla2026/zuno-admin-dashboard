import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';

/// A coloured circle (or rounded square) with initials, or the person's
/// photo when [imageUrl] is given. The initials stay on screen while the photo
/// loads and replace it if the photo cannot be shown.
class AppInitialsAvatar extends StatelessWidget {
  const AppInitialsAvatar({
    super.key,
    required this.initials,
    required this.color,
    this.size = 34,
    this.borderRadius,
    this.textStyle,
    this.imageUrl,
  });

  final String initials;
  final Color color;
  final double size;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final initialsAvatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadius,
      ),
      child: Text(
        initials,
        style: (textStyle ?? AppTextStyles.labelSmall).copyWith(
          color: AppColors.white,
        ),
      ),
    );

    final url = imageUrl;
    if (url == null) return initialsAvatar;

    final image = Image.network(
      url,
      // Keyed by URL so a reused row never keeps another user's photo.
      key: ValueKey(url),
      width: size,
      height: size,
      fit: BoxFit.cover,
      // Firebase Storage URLs may lack CORS headers; fall back to an <img>.
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : initialsAvatar,
      errorBuilder: (context, _, _) => initialsAvatar,
    );

    return SizedBox.square(
      dimension: size,
      child: borderRadius == null
          ? ClipOval(child: image)
          : ClipRRect(borderRadius: borderRadius!, child: image),
    );
  }
}
