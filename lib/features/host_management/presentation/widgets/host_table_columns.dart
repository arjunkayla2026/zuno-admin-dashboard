import 'package:flutter/material.dart';

class HostTableColumns extends StatelessWidget {
  const HostTableColumns({
    super.key,
    required this.createdDate,
    required this.name,
    required this.hostId,
    required this.phone,
    required this.status,
    required this.wallet,
    required this.action,
  });

  static const double minWidth = 1100;
  static const double leftInset = 14;

  final Widget createdDate;
  final Widget name;
  final Widget hostId;
  final Widget phone;
  final Widget status;
  final Widget wallet;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: leftInset),
      child: Row(
        children: [
          Expanded(flex: 88, child: createdDate),
          Expanded(flex: 141, child: name),
          Expanded(flex: 66, child: hostId),
          Expanded(flex: 117, child: phone),
          Expanded(flex: 120, child: status),
          Expanded(
            flex: 82,
            child: Align(alignment: Alignment.centerRight, child: wallet),
          ),
          Expanded(
            flex: 196,
            child: Align(alignment: Alignment.center, child: action),
          ),
          const Spacer(flex: 32),
        ],
      ),
    );
  }
}
