import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';

class AppDashedDivider extends StatelessWidget {
  const AppDashedDivider({super.key, this.color = AppColors.cardBorder});

  static const double _thickness = 1;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _thickness,
      width: double.infinity,
      child: CustomPaint(painter: _DashedLinePainter(color)),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter(this.color);

  static const double _dash = 3;
  static const double _gap = 3;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height;
    final y = size.height / 2;

    for (double x = 0; x < size.width; x += _dash + _gap) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + _dash, size.width), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
