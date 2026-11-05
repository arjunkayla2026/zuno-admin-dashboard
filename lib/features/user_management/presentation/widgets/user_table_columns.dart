import 'package:flutter/material.dart';

class UserTableColumns extends StatelessWidget {
  const UserTableColumns({
    super.key,
    required this.createdDate,
    required this.name,
    required this.userId,
    required this.phone,
    required this.recharges,
    required this.wallet,
    required this.action,
  });

  static const double minWidth = 1100;
  static const double leftInset = 14;

  final Widget createdDate;
  final Widget name;
  final Widget userId;
  final Widget phone;
  final Widget recharges;
  final Widget wallet;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: leftInset),
      child: Row(
        children: [
          Expanded(flex: 152, child: createdDate),
          Expanded(flex: 263, child: name),
          Expanded(flex: 115, child: userId),
          Expanded(flex: 206, child: phone),
          Expanded(
            flex: 93,
            child: Align(alignment: Alignment.centerRight, child: recharges),
          ),
          Expanded(
            flex: 158,
            child: Align(alignment: Alignment.centerRight, child: wallet),
          ),
          const Spacer(flex: 127),
          Expanded(flex: 272, child: action),
        ],
      ),
    );
  }
}
