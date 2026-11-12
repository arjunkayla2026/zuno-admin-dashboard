import 'package:flutter/material.dart';

class AppWeightStableText extends StatelessWidget {
  const AppWeightStableText(
    this.text, {
    super.key,
    required this.style,
    required this.widestStyle,
  });

  final String text;
  final TextStyle style;
  final TextStyle widestStyle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Text(text, style: widestStyle),
        ),
        Text(text, style: style),
      ],
    );
  }
}
