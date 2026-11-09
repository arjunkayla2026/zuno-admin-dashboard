import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_header.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_segmented_control.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/banner_drop_target.dart';

class AddBannerDialog extends StatefulWidget {
  const AddBannerDialog({super.key, required this.fileName});

  final String fileName;

  @override
  State<AddBannerDialog> createState() => _AddBannerDialogState();
}

class _AddBannerDialogState extends State<AddBannerDialog> {
  static const double _width = 640;
  static const double _segmentWidth = 124;
  static const double _dropZoneHeight = 186;
  static const double _segmentGap = 20;
  static const double _actionsGap = 24;
  static const double _actionSpacing = 10;
  static const EdgeInsets _headerPadding = EdgeInsets.fromLTRB(24, 22, 24, 12);
  static const EdgeInsets _bodyPadding = EdgeInsets.fromLTRB(24, 20, 24, 16);

  BannerAudience _audience = BannerAudience.user;
  bool _imageChosen = false;

  @override
  Widget build(BuildContext context) {
    return AppDialogSurface(
      width: _width,
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: _headerPadding,
              child: AppDialogHeader(
                icon: SvgPicture.asset(
                  AppImages.bannerImageIcon,
                  width: AppDialogHeader.iconSize,
                  height: AppDialogHeader.iconSize,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primaryDark,
                    BlendMode.srcIn,
                  ),
                ),
                title: AppStrings.addBannerImage,
                subtitle: AppStrings.screenPlacementHome,
              ),
            ),
            const Divider(color: AppColors.cardBorder),
            Padding(
              padding: _bodyPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: AppSegmentedControl<BannerAudience>(
                      options: const {
                        BannerAudience.user: AppStrings.userAudience,
                        BannerAudience.host: AppStrings.hostAudience,
                      },
                      value: _audience,
                      segmentWidth: _segmentWidth,
                      onChanged: (audience) =>
                          setState(() => _audience = audience),
                    ),
                  ),
                  const SizedBox(height: _segmentGap),
                  BannerDropTarget(
                    height: _dropZoneHeight,
                    iconAsset: AppImages.uploadIcon,
                    tileColor: AppColors.statTileBackground,
                    iconColor: AppColors.segmentText,
                    title: _imageChosen
                        ? widget.fileName
                        : AppStrings.bannerDropTitle,
                    helper: AppStrings.bannerDropHint,
                    helperColor: AppColors.dialogMessage,
                    onTap: () => setState(() => _imageChosen = true),
                  ),
                  const SizedBox(height: _actionsGap),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: _actionSpacing,
                    runSpacing: AppUtils.spacingSm,
                    children: [
                      AppSecondaryButton(
                        label: AppStrings.cancel,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      AppPrimaryButton(
                        label: AppStrings.addBannerAction,
                        compact: true,
                        onPressed: _imageChosen
                            ? () => Navigator.of(context).pop(_audience)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
