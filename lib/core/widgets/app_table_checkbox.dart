import 'package:flutter/material.dart';

class AppTableCheckbox extends StatelessWidget {
  const AppTableCheckbox({
    super.key,
    required this.value,
    required this.onToggle,
  });

  final bool? value;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final onToggle = this.onToggle;
    return Checkbox(
      value: value,
      tristate: value == null,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      onChanged: onToggle == null ? null : (_) => onToggle(),
    );
  }
}
