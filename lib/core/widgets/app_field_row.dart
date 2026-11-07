import 'package:flutter/material.dart';

class AppFieldRow extends StatelessWidget {
  const AppFieldRow({
    super.key,
    required this.first,
    required this.second,
    this.gap = 12,
    this.stackBelowWidth = 420,
  });

  final Widget first;
  final Widget second;
  final double gap;
  final double stackBelowWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < stackBelowWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              first,
              SizedBox(height: gap),
              second,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            SizedBox(width: gap),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}
