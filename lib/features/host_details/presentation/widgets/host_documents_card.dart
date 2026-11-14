import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/documents/app_identity_documents.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';

class HostDocumentsCard extends StatelessWidget {
  const HostDocumentsCard({super.key, required this.host});

  static const double _titleGap = 12;
  static const EdgeInsets _padding = EdgeInsets.all(14);

  final AdminHost host;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.hostUploadedDocuments,
            style: AppTextStyles.cardTitle.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: _titleGap),
          AppIdentityDocuments(
            name: host.fullName,
            maskedAadhaar: AppStrings.emptyValue,
            initials: host.initials,
            avatarIndex: host.avatarIndex,
            aadhaarImageUrl: host.aadhaarImageUrl,
            selfieImageUrl: host.selfieImageUrl,
          ),
        ],
      ),
    );
  }
}
