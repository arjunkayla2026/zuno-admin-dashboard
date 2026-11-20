import 'package:flutter/material.dart';

class AppTextSelectionScope extends StatefulWidget {
  const AppTextSelectionScope({super.key, required this.child});

  final Widget child;

  @override
  State<AppTextSelectionScope> createState() => _AppTextSelectionScopeState();
}

class _AppTextSelectionScopeState extends State<AppTextSelectionScope> {
  late final OverlayEntry _entry = OverlayEntry(
    builder: (_) => SelectionArea(child: widget.child),
  );

  @override
  void didUpdateWidget(covariant AppTextSelectionScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) _entry.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) => Overlay(initialEntries: [_entry]);
}
