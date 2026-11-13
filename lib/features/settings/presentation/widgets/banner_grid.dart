import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/banner_card.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/banner_drop_target.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/banner_flow.dart';

class BannerGrid extends StatelessWidget {
  const BannerGrid({super.key, required this.banners});

  static const double _gap = 20;
  static const double _minCardWidth = 320;
  static const double _addTileHeight = 218;
  static const int _maxColumns = 3;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(20, 22, 20, 20);

  final List<BannerImage> banners;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns =
              ((constraints.maxWidth + _gap) / (_minCardWidth + _gap))
                  .floor()
                  .clamp(1, _maxColumns);
          final width = (constraints.maxWidth - _gap * (columns - 1)) / columns;

          return Wrap(
            spacing: _gap,
            runSpacing: _gap,
            children: [
              for (final (index, banner) in banners.indexed)
                SizedBox(
                  width: width,
                  child: BannerCard(
                    number: index + 1,
                    banner: banner,
                    onDelete: () => confirmDeleteBanner(context, banner),
                  ),
                ),
              SizedBox(
                width: width,
                child: Builder(
                  builder: (tileContext) => BannerDropTarget(
                    height: _addTileHeight,
                    iconAsset: AppImages.bannerImageIcon,
                    tileColor: AppColors.iconTileBackground,
                    iconColor: AppColors.primaryDark,
                    title: AppStrings.addBannerImage,
                    helper: AppStrings.bannerFormatHint,
                    helperColor: context.appColors.textTertiary,
                    onTap: () => openAddBannerDialog(tileContext),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
