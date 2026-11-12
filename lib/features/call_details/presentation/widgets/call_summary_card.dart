import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/features/call_details/presentation/widgets/call_participants.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';
import 'package:zuno_admin_dashboard/features/calls/presentation/widgets/call_log_labels.dart';

class CallSummaryCard extends StatelessWidget {
  const CallSummaryCard({super.key, required this.call});

  static const double _tileSize = 50;
  static const double _iconSize = 24;
  static const double _tileGap = 16;
  static const double _titleGap = 10;
  static const double _subtitleGap = 4;
  static const double _sideBySideWidth = 720;
  static const EdgeInsets _padding = EdgeInsets.all(16);

  final CallLog call;

  @override
  Widget build(BuildContext context) {
    final isVideo = call.type == CallLogType.video;
    final textColor = context.colorScheme.onSurface;
    final muted = context.appColors.textSecondary;
    final footnote = AppTextStyles.tableFootnote.copyWith(color: muted);
    final mono = AppTextStyles.monoSmall.copyWith(color: muted);
    final (statusLabel, status) = CallLogLabels.status(call);

    final summary = Row(
      children: [
        Container(
          width: _tileSize,
          height: _tileSize,
          decoration: BoxDecoration(
            color: AppColors.iconTileBackground,
            borderRadius: AppUtils.radiusSmall,
          ),
          child: Icon(
            isVideo ? Icons.videocam_outlined : Icons.mic_none_rounded,
            size: _iconSize,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(width: _tileGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: _titleGap,
                runSpacing: AppUtils.spacingXs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    isVideo
                        ? AppStrings.videoCallTitle
                        : AppStrings.audioCallTitle,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: textColor,
                    ),
                  ),
                  AppStatusBadge(label: statusLabel, status: status),
                ],
              ),
              const SizedBox(height: _subtitleGap),
              Text.rich(
                TextSpan(
                  style: footnote,
                  children: [
                    TextSpan(text: DateFormatter.short(call.initiatedAt)),
                    const TextSpan(
                      text: '${AppStrings.metaSeparator}${AppStrings.callId} ',
                    ),
                    TextSpan(text: call.callId, style: mono),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
    final participants = CallParticipants(call: call);

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < _sideBySideWidth) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: AppUtils.spacingLg),
                participants,
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: summary),
              const SizedBox(width: AppUtils.spacingLg),
              participants,
            ],
          );
        },
      ),
    );
  }
}
