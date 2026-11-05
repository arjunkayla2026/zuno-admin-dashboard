import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({super.key, required this.label, required this.status});

  static const double _dotSize = 5;
  static const double _dotGap = 5;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 9,
    vertical: 4,
  );

  final String label;
  final AppStatus status;

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.statusColors(context, status).foreground;

    return Container(
      padding: _padding,
      decoration: AppUtils.statusBadgeDecoration(context, status),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _dotSize,
            height: _dotSize,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: _dotGap),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.tableFootnote.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
