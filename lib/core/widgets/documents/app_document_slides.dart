import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

/// One side of a document shown in [AppDocumentSlides].
class AppDocumentSlide {
  const AppDocumentSlide({required this.label, required this.preview});

  final String label;
  final Widget preview;
}

/// Pages through the sides of one document (e.g. Aadhaar front and back)
/// inside a document preview. Slides by swiping, by dragging with a mouse
/// or trackpad, or with the arrow buttons; the pill shows which side is
/// open.
class AppDocumentSlides extends StatefulWidget {
  const AppDocumentSlides({super.key, required this.slides});

  final List<AppDocumentSlide> slides;

  @override
  State<AppDocumentSlides> createState() => _AppDocumentSlidesState();
}

class _AppDocumentSlidesState extends State<AppDocumentSlides> {
  static const Duration _slideDuration = Duration(milliseconds: 250);
  static const double _arrowSize = 36;
  static const double _arrowIconSize = 22;
  static const double _overlayOpacity = 0.55;
  static const EdgeInsets _pillPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );

  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) => _controller.animateToPage(
    page,
    duration: _slideDuration,
    curve: Curves.easeOut,
  );

  Widget _arrow({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: _overlayOpacity),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: _arrowSize,
            child: Icon(icon, size: _arrowIconSize, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.slides;
    final count = slides.length;
    final hasPrevious = _page > 0;
    final hasNext = _page < count - 1;

    return Stack(
      children: [
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context)
              .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
          child: PageView(
            controller: _controller,
            onPageChanged: (page) => setState(() => _page = page),
            children: [for (final slide in slides) slide.preview],
          ),
        ),
        if (count > 1) ...[
          if (hasPrevious)
            Positioned(
              left: AppUtils.spacingSm,
              top: 0,
              bottom: 0,
              child: Center(
                child: _arrow(
                  icon: Icons.chevron_left_rounded,
                  tooltip: slides[_page - 1].label,
                  onPressed: () => _goTo(_page - 1),
                ),
              ),
            ),
          if (hasNext)
            Positioned(
              right: AppUtils.spacingSm,
              top: 0,
              bottom: 0,
              child: Center(
                child: _arrow(
                  icon: Icons.chevron_right_rounded,
                  tooltip: slides[_page + 1].label,
                  onPressed: () => _goTo(_page + 1),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppUtils.spacingSm,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: _overlayOpacity),
                  borderRadius: AppUtils.radiusSmall,
                ),
                child: Padding(
                  padding: _pillPadding,
                  child: Text(
                    AppStrings.documentSlideLabel(
                      slides[_page].label,
                      _page + 1,
                      count,
                    ),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
