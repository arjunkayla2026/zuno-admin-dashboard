import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_section_card.dart';
import 'package:zuno_admin_dashboard/features/dashboard/data/models/dashboard_stat.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/widgets/stat_tile.dart';

class StatSection extends StatelessWidget {
  const StatSection({
    super.key,
    required this.title,
    required this.rangeLabel,
    required this.stats,
    required this.columns,
    this.tileMinHeight = 78,
  });

  static const double _gap = 12;
  static const double _rowGap = 13;
  static const double _minTileWidth = 150;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 16,
  );

  final String title;
  final String rangeLabel;
  final List<DashboardStat> stats;
  final int columns;
  final double tileMinHeight;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: title,
      subtitle: rangeLabel,
      child: Padding(
        padding: _padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final fitting = ((maxWidth + _gap) / (_minTileWidth + _gap))
                .floor()
                .clamp(1, columns);
            final tileWidth = (maxWidth - _gap * (fitting - 1)) / fitting;

            return Wrap(
              spacing: _gap,
              runSpacing: _rowGap,
              children: [
                for (final stat in stats)
                  SizedBox(
                    width: tileWidth,
                    child: StatTile(stat: stat, minHeight: tileMinHeight),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
