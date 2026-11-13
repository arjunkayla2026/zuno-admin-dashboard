import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zuno_admin_dashboard/core/di/injection_container.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_header.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_error_banner.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_segmented_control.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_upload.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/banner_drop_target.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/banner_labels.dart';

class AddBannerDialog extends StatefulWidget {
  const AddBannerDialog({
    super.key,
    required this.screen,
    required this.onSubmit,
  });

  final BannerScreen screen;
  final Future<String?> Function(BannerUpload upload) onSubmit;

  @override
  State<AddBannerDialog> createState() => _AddBannerDialogState();
}

class _AddBannerDialogState extends State<AddBannerDialog> {
  static const double _width = 640;
  static const double _segmentWidth = 124;
  static const double _dropZoneHeight = 186;
  static const double _previewHeight = 182;
  static const double _segmentGap = 20;
  static const double _actionsGap = 24;
  static const double _actionSpacing = 10;
  static const int _maxBytes = 5 * 1024 * 1024;
  static const Map<String, String> _contentTypes = {
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
  };
  static const EdgeInsets _headerPadding = EdgeInsets.fromLTRB(24, 22, 24, 12);
  static const EdgeInsets _bodyPadding = EdgeInsets.fromLTRB(24, 20, 24, 16);

  late BannerAudience _audience = widget.screen.audiences.first;
  BannerUpload? _upload;
  String? _errorMessage;
  bool _saving = false;

  String? _contentTypeOf(XFile file) {
    final mimeType = file.mimeType;
    if (mimeType != null && _contentTypes.containsValue(mimeType)) {
      return mimeType;
    }
    final name = file.name.toLowerCase();
    final dot = name.lastIndexOf('.');
    return dot < 0 ? null : _contentTypes[name.substring(dot)];
  }

  Future<void> _pickImage() async {
    try {
      final file = await getIt<ImagePicker>().pickImage(
        source: ImageSource.gallery,
      );
      if (file == null || !mounted) return;

      final contentType = _contentTypeOf(file);
      if (contentType == null) {
        return setState(() => _errorMessage = AppStrings.bannerInvalidType);
      }
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (bytes.length > _maxBytes) {
        return setState(() => _errorMessage = AppStrings.bannerTooLarge);
      }

      setState(() {
        _errorMessage = null;
        _upload = BannerUpload(
          bytes: bytes,
          fileName: file.name,
          contentType: contentType,
          role: _audience,
          screen: widget.screen,
        );
      });
    } catch (_) {
      if (mounted) setState(() => _errorMessage = AppStrings.bannerPickFailed);
    }
  }

  Future<void> _submit() async {
    final upload = _upload;
    if (upload == null) return;

    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    final error = await widget.onSubmit(
      BannerUpload(
        bytes: upload.bytes,
        fileName: upload.fileName,
        contentType: upload.contentType,
        role: _audience,
        screen: widget.screen,
      ),
    );
    if (!mounted) return;

    if (error == null) return Navigator.of(context).pop();
    setState(() {
      _saving = false;
      _errorMessage = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final upload = _upload;

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
                subtitle: AppStrings.screenPlacementOf(
                  BannerLabels.screen(widget.screen),
                ),
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
                      options: {
                        for (final audience in widget.screen.audiences)
                          audience: BannerLabels.audience(audience),
                      },
                      value: _audience,
                      segmentWidth: _segmentWidth,
                      onChanged: (audience) {
                        if (!_saving) setState(() => _audience = audience);
                      },
                    ),
                  ),
                  const SizedBox(height: _segmentGap),
                  if (upload != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      child: Image.memory(
                        upload.bytes,
                        height: _previewHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: AppUtils.spacingMd),
                  ],
                  BannerDropTarget(
                    height: _dropZoneHeight,
                    iconAsset: AppImages.uploadIcon,
                    tileColor: AppColors.statTileBackground,
                    iconColor: AppColors.segmentText,
                    title: upload?.fileName ?? AppStrings.bannerDropTitle,
                    helper: AppStrings.bannerDropHint,
                    helperColor: AppColors.dialogMessage,
                    onTap: _saving ? null : _pickImage,
                  ),
                  if (_errorMessage case final message?) ...[
                    const SizedBox(height: AppUtils.spacingMd),
                    AppErrorBanner(message: message),
                  ],
                  const SizedBox(height: _actionsGap),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: _actionSpacing,
                    runSpacing: AppUtils.spacingSm,
                    children: [
                      AppSecondaryButton(
                        label: AppStrings.cancel,
                        onPressed: _saving
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                      AppPrimaryButton(
                        label: _saving
                            ? AppStrings.addingBanner
                            : AppStrings.addBannerAction,
                        compact: true,
                        onPressed: upload == null || _saving ? null : _submit,
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
