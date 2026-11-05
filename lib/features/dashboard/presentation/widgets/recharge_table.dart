import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';
import 'package:zuno_admin_dashboard/features/dashboard/data/models/recharge_activity.dart';

class RechargeTable extends StatelessWidget {
  const RechargeTable({super.key, required this.recharges});

  static const double _minWidth = 760;
  static const double _headerHeight = 36;
  static const double _rowHeight = 55;
  static const double _sidePadding = 14;
  static const double _timeInset = 26;
  static const double _avatarGap = 10;
  static const int _nameFlex = 423;
  static const int _idFlex = 255;
  static const int _amountFlex = 256;
  static const int _timeFlex = 452;

  static const List<Color> _avatarColors = [
    AppColors.avatarBlue,
    AppColors.avatarRed,
    AppColors.avatarGreen,
    AppColors.avatarMagenta,
  ];

  final List<RechargeActivity> recharges;

  Color _avatarColor(int index) => _avatarColors[index % _avatarColors.length];

  Widget _row({
    required double height,
    required Widget name,
    required Widget id,
    required Widget amount,
    required Widget time,
    Color? color,
    bool showDivider = true,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
      padding: const EdgeInsets.only(left: _sidePadding),
      decoration: BoxDecoration(
        color: color,
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.cardBorder))
            : null,
      ),
      child: Row(
        children: [
          Expanded(flex: _nameFlex, child: name),
          Expanded(flex: _idFlex, child: id),
          Expanded(
            flex: _amountFlex,
            child: Align(alignment: Alignment.centerRight, child: amount),
          ),
          Expanded(
            flex: _timeFlex,
            child: Padding(
              padding: const EdgeInsets.only(left: _timeInset),
              child: time,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = AppTextStyles.labelSmall.copyWith(
      color: context.appColors.textSecondary,
      fontWeight: FontWeight.w500,
    );
    final textColor = context.colorScheme.onSurface;

    return LayoutBuilder(
      builder: (context, constraints) {
        final table = Column(
          children: [
            _row(
              height: _headerHeight,
              color: AppColors.tableHeaderBackground,
              name: Text(AppStrings.userName, style: headerStyle),
              id: Text(AppStrings.userId, style: headerStyle),
              amount: Text(AppStrings.rechargeAmount, style: headerStyle),
              time: Text(AppStrings.rechargeTime, style: headerStyle),
            ),
            for (final (index, recharge) in recharges.indexed)
              _row(
                height: _rowHeight,
                showDivider: index != recharges.length - 1,
                name: Row(
                  children: [
                    AppInitialsAvatar(
                      initials: recharge.userInitials,
                      color: _avatarColor(index),
                    ),
                    const SizedBox(width: _avatarGap),
                    Expanded(
                      child: Text(
                        recharge.userName,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                id: Text(
                  recharge.userId,
                  style: AppTextStyles.mono.copyWith(color: textColor),
                ),
                amount: Text(
                  recharge.amount,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                time: Text(
                  recharge.time,
                  style: AppTextStyles.bodySmall.copyWith(color: textColor),
                ),
              ),
          ],
        );

        if (constraints.maxWidth >= _minWidth) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: _minWidth, child: table),
        );
      },
    );
  }
}
