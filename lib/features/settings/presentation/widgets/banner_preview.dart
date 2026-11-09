import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';

class BannerPreview extends StatelessWidget {
  const BannerPreview({super.key, required this.banner});

  static const double _minHeight = 182;
  static const double _largeCircle = 186;
  static const double _largeCircleTop = -46;
  static const double _largeCircleRight = -29;
  static const double _smallCircle = 108;
  static const double _smallCircleBottom = -23;
  static const double _smallCircleRight = -6;
  static const double _subheadingGap = 7;
  static const double _actionGap = 14;
  static const double _actionHeight = 28;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(30, 24, 30, 25);
  static const EdgeInsets _actionPadding = EdgeInsets.symmetric(horizontal: 20);

  final BannerImage banner;

  LinearGradient get _gradient => switch (banner.artwork) {
    BannerArtwork.navy => AppColors.navyGradient,
    BannerArtwork.brown => AppColors.brownGradient,
    BannerArtwork.teal => AppColors.tealGradient,
  };

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.bannerCircle,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: _minHeight),
      decoration: BoxDecoration(gradient: _gradient),
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          Positioned(
            top: _largeCircleTop,
            right: _largeCircleRight,
            child: _circle(_largeCircle),
          ),
          Positioned(
            bottom: _smallCircleBottom,
            right: _smallCircleRight,
            child: _circle(_smallCircle),
          ),
          Padding(
            padding: _padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.headline,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: _subheadingGap),
                Text(
                  banner.subheading,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.bannerSubheading,
                  ),
                ),
                const SizedBox(height: _actionGap),
                Container(
                  height: _actionHeight,
                  padding: _actionPadding,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppUtils.radiusPill,
                  ),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      banner.actionLabel,
                      style: AppTextStyles.tableFootnote.copyWith(
                        color: AppColors.onPrimaryButton,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
