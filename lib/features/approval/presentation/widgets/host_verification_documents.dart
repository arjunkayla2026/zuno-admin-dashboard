import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/core/widgets/documents/app_aadhaar_card_preview.dart';
import 'package:zuno_admin_dashboard/core/widgets/documents/app_document_image.dart';
import 'package:zuno_admin_dashboard/core/widgets/documents/app_document_preview_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/documents/app_document_tile.dart';
import 'package:zuno_admin_dashboard/core/widgets/documents/app_selfie_preview.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/host_request.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/host_request_labels.dart';

class HostVerificationDocuments extends StatelessWidget {
  const HostVerificationDocuments({
    super.key,
    required this.request,
    required this.isBusy,
    required this.onReview,
  });

  static const double _gap = 12;
  static const double _threeColumnWidth = 480;
  static const double _selfieAvatarSize = 200;
  static const double _selfieThumbnailSize = 64;
  static const double _missingIconSize = 28;
  static const double _selfieAspectRatio = 1;

  final HostRequest request;
  final bool isBusy;
  final void Function(HostDocument document, HostRequestStatus decision)
  onReview;

  Widget _placeholder(
    BuildContext context,
    HostDocumentType type,
    double avatarSize,
  ) {
    return switch (type) {
      HostDocumentType.aadhaarFront => AppAadhaarCardPreview(
        name: request.realName,
        maskedNumber: request.maskedAadhaar,
      ),
      HostDocumentType.aadhaarBack => ColoredBox(
        color: context.appColors.uploadBackground,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: _missingIconSize,
            color: context.appColors.uploadBorder,
          ),
        ),
      ),
      HostDocumentType.selfie => AppSelfiePreview(
        initials: request.initials,
        avatarIndex: request.avatarIndex,
        avatarSize: avatarSize,
      ),
    };
  }

  void _preview(BuildContext context, HostDocument document) {
    const card = AppAadhaarCardPreview.cardSize;
    final isSelfie = document.type == HostDocumentType.selfie;
    showAppDocumentPreview(
      context: context,
      title: AppStrings.documentPreviewTitle(
        HostRequestLabels.document(document.type),
        request.realName,
      ),
      aspectRatio: isSelfie ? _selfieAspectRatio : card.width / card.height,
      preview: AppDocumentImage(
        imageUrl: document.imageUrl,
        fit: BoxFit.contain,
        placeholder: _placeholder(context, document.type, _selfieAvatarSize),
      ),
    );
  }

  Widget _card(BuildContext context, HostDocument document) {
    final (statusLabel, status) = HostRequestLabels.status(document.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDocumentTile(
          label: HostRequestLabels.document(document.type),
          preview: AppDocumentImage(
            imageUrl: document.imageUrl,
            placeholder: _placeholder(
              context,
              document.type,
              _selfieThumbnailSize,
            ),
          ),
          onTap: () => _preview(context, document),
        ),
        const SizedBox(height: AppUtils.spacingSm),
        AppStatusBadge(label: statusLabel, status: status),
        if (document.canReview) ...[
          const SizedBox(height: AppUtils.spacingSm),
          Wrap(
            spacing: AppUtils.spacingSm,
            runSpacing: AppUtils.spacingXs,
            children: [
              AppSecondaryButton(
                label: AppStrings.reject,
                small: true,
                destructive: true,
                onPressed: isBusy
                    ? null
                    : () => onReview(document, HostRequestStatus.rejected),
              ),
              AppPrimaryButton(
                label: AppStrings.approve,
                small: true,
                positive: true,
                onPressed: isBusy
                    ? null
                    : () => onReview(document, HostRequestStatus.approved),
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= _threeColumnWidth ? 3 : 1;
        final width = (constraints.maxWidth - _gap * (columns - 1)) / columns;

        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final document in request.documents)
              SizedBox(width: width, child: _card(context, document)),
          ],
        );
      },
    );
  }
}
