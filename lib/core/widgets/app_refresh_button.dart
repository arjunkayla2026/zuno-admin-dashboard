import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';

class AppRefreshButton extends StatefulWidget {
  const AppRefreshButton({
    super.key,
    required this.onRefresh,
    this.refreshing = false,
  });

  final Future<void> Function()? onRefresh;
  final bool refreshing;

  @override
  State<AppRefreshButton> createState() => _AppRefreshButtonState();
}

class _AppRefreshButtonState extends State<AppRefreshButton> {
  static const double _iconSize = 18;
  static const double _loaderStroke = 2;

  bool _running = false;

  Future<void> _refresh() async {
    final onRefresh = widget.onRefresh;
    if (onRefresh == null || _running) return;
    setState(() => _running = true);
    try {
      await onRefresh();
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _running || widget.refreshing;

    return AppSecondaryButton(
      label: AppStrings.refresh,
      onPressed: busy || widget.onRefresh == null ? null : _refresh,
      leading: busy
          ? SizedBox.square(
              dimension: _iconSize,
              child: CircularProgressIndicator(
                strokeWidth: _loaderStroke,
                color: context.appColors.textSecondary,
              ),
            )
          : const Icon(Icons.refresh_rounded, size: _iconSize),
    );
  }
}
