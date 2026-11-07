import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/core/widgets/documents/app_document_image.dart';
import 'package:zuno_admin_dashboard/core/widgets/documents/app_selfie_preview.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/profile_photo_request.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/profile_photo_flow.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/host_profile_labels.dart';

class ProfilePhotoCard extends StatelessWidget {
  const ProfilePhotoCard({super.key, required this.photo});

  static const double _photoAspectRatio = 1.48;
  static const double _placeholderAvatarSize = 72;
  static const double _idGap = 8;
  static const double _lineGap = 2;
  static const double _actionsGap = 12;
  static const double _buttonGap = 10;
  static const EdgeInsets _bodyPadding = EdgeInsets.fromLTRB(12, 12, 12, 12);

  final ProfilePhotoRequest photo;

  static (String, AppStatus) _status(ProfilePhotoStatus status) =>
      switch (status) {
        ProfilePhotoStatus.pending => (AppStrings.pending, AppStatus.pending),
        ProfilePhotoStatus.accepted => (AppStrings.accepted, AppStatus.active),
        ProfilePhotoStatus.rejected => (AppStrings.rejected, AppStatus.error),
      };

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final muted = context.appColors.textSecondary;
    final caption = AppTextStyles.captionSmall.copyWith(color: muted);
    final (statusLabel, status) = _status(photo.status);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: _photoAspectRatio,
            child: AppDocumentImage(
              imageUrl: photo.photoUrl,
              placeholder: AppSelfiePreview(
                initials: photo.initials,
                avatarIndex: photo.avatarIndex,
                avatarSize: _placeholderAvatarSize,
              ),
            ),
          ),
          Padding(
            padding: _bodyPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        photo.hostName,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AppStatusBadge(label: statusLabel, status: status),
                  ],
                ),
                const SizedBox(height: _idGap),
                Text(
                  photo.hostId,
                  style: AppTextStyles.monoSmall.copyWith(color: muted),
                ),
                const SizedBox(height: _lineGap),
                Text(
                  AppStrings.nameAndCity(photo.realName, photo.city),
                  style: caption,
                ),
                const SizedBox(height: _lineGap),
                Text(
                  AppStrings.languagesSubmitted(
                    HostProfileLabels.languageList(photo.languages),
                    DateFormatter.short(photo.submittedOn),
                  ),
                  style: caption,
                ),
                if (photo.isPending) ...[
                  const SizedBox(height: _actionsGap),
                  Row(
                    children: [
                      Expanded(
                        child: AppSecondaryButton(
                          label: AppStrings.reject,
                          destructive: true,
                          small: true,
                          onPressed: () =>
                              decideProfilePhoto(context, photo, accept: false),
                        ),
                      ),
                      const SizedBox(width: _buttonGap),
                      Expanded(
                        child: AppPrimaryButton(
                          label: AppStrings.accept,
                          small: true,
                          positive: true,
                          onPressed: () =>
                              decideProfilePhoto(context, photo, accept: true),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
