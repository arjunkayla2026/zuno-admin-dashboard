import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_card.dart';
import 'package:zuno_admin_dashboard/features/calls/data/models/call_log.dart';

class CallTimelineCard extends StatelessWidget {
  const CallTimelineCard({super.key, required this.call});

  static const double _minItemWidth = 150;
  static const double _runGap = 14;

  final CallLog call;

  @override
  Widget build(BuildContext context) {
    final startedAt = call.startedAt;
    final duration = call.durationSeconds;
    final items = [
      (
        AppStrings.callInitiatedTime,
        DateFormatter.timeWithSeconds(call.initiatedAt),
      ),
      (
        AppStrings.callStartTime,
        startedAt == null
            ? AppStrings.emptyValue
            : DateFormatter.timeWithSeconds(startedAt),
      ),
      (AppStrings.callEndTime, DateFormatter.timeWithSeconds(call.endedAt)),
      (
        AppStrings.callDuration,
        duration == null
            ? AppStrings.emptyValue
            : DateFormatter.shortDuration(duration),
      ),
      (AppStrings.callEndedBy, call.endedBy),
    ];

    return AppLabeledCard(
      label: AppStrings.callTimeline,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = (constraints.maxWidth / _minItemWidth).floor().clamp(
            1,
            items.length,
          );
          final width = constraints.maxWidth / columns;

          return Wrap(
            runSpacing: _runGap,
            children: [
              for (final (label, value) in items)
                SizedBox(
                  width: width,
                  child: _TimelineItem(label: label, value: value),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.label, required this.value});

  static const double _dotSize = 15;
  static const double _ringWidth = 3;
  static const double _dotGap = 8;
  static const double _dotTopInset = 0;
  static const double _valueGap = 2;

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: _dotTopInset),
          child: Container(
            width: _dotSize,
            height: _dotSize,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: colors.primarySoft, width: _ringWidth),
            ),
          ),
        ),
        const SizedBox(width: _dotGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.captionSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: _valueGap),
              Text(
                value,
                style: AppTextStyles.labelMedium.copyWith(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
