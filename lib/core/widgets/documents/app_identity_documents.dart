import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/documents/app_aadhaar_card_preview.dart';
import 'package:zuno_admin_dashboard/core/widgets/documents/app_document_image.dart';
import 'package:zuno_admin_dashboard/core/widgets/documents/app_document_preview_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/documents/app_document_tile.dart';
import 'package:zuno_admin_dashboard/core/widgets/documents/app_selfie_preview.dart';

class AppIdentityDocuments extends StatelessWidget {
  const AppIdentityDocuments({
    super.key,
    required this.name,
    required this.maskedAadhaar,
    required this.initials,
    required this.avatarIndex,
    this.aadhaarImageUrl,
    this.selfieImageUrl,
    this.aadhaarLabel = AppStrings.aadhaarCard,
    this.selfieLabel = AppStrings.selfie,
  });

  static const double _tileGap = 8;
  static const double _selfieAspectRatio = 1;
  static const double _selfieAvatarSize = 200;

  final String name;
  final String maskedAadhaar;
  final String initials;
  final int avatarIndex;
  final String? aadhaarImageUrl;
  final String? selfieImageUrl;
  final String aadhaarLabel;
  final String selfieLabel;

  Widget _aadhaar({BoxFit fit = BoxFit.cover}) => AppDocumentImage(
    imageUrl: aadhaarImageUrl,
    fit: fit,
    placeholder: AppAadhaarCardPreview(name: name, maskedNumber: maskedAadhaar),
  );

  Widget _selfie({double avatarSize = 64, BoxFit fit = BoxFit.cover}) =>
      AppDocumentImage(
        imageUrl: selfieImageUrl,
        fit: fit,
        placeholder: AppSelfiePreview(
          initials: initials,
          avatarIndex: avatarIndex,
          avatarSize: avatarSize,
        ),
      );

  void _previewAadhaar(BuildContext context) {
    const size = AppAadhaarCardPreview.cardSize;
    showAppDocumentPreview(
      context: context,
      title: AppStrings.documentPreviewTitle(AppStrings.aadhaarCard, name),
      aspectRatio: size.width / size.height,
      preview: _aadhaar(fit: BoxFit.contain),
    );
  }

  void _previewSelfie(BuildContext context) {
    showAppDocumentPreview(
      context: context,
      title: AppStrings.documentPreviewTitle(AppStrings.selfie, name),
      aspectRatio: _selfieAspectRatio,
      preview: _selfie(avatarSize: _selfieAvatarSize, fit: BoxFit.contain),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppDocumentTile(
            label: aadhaarLabel,
            preview: _aadhaar(),
            onTap: () => _previewAadhaar(context),
          ),
        ),
        const SizedBox(width: _tileGap),
        Expanded(
          child: AppDocumentTile(
            label: selfieLabel,
            preview: _selfie(),
            onTap: () => _previewSelfie(context),
          ),
        ),
      ],
    );
  }
}
