import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';

class AppTableColumn {
  const AppTableColumn(this.label, this.width, {this.alignEnd = false});

  final String label;
  final double width;
  final bool alignEnd;
}

class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
  });

  static const double _leftInset = 10;
  static const double _endColumnInset = 20;
  static const double _headerHeight = 38;
  static const double _rowHeight = 45;

  final List<AppTableColumn> columns;
  final List<List<Widget>> rows;
  final ValueChanged<int>? onRowTap;

  double get _rightInset => columns.last.alignEnd ? _endColumnInset : 0;

  double get _contentWidth =>
      _leftInset +
      _rightInset +
      columns.fold(0, (sum, column) => sum + column.width);

  Widget _row(List<Widget> cells, double extraWidth) {
    return Padding(
      padding: EdgeInsets.only(left: _leftInset, right: _rightInset),
      child: Row(
        children: [
          for (final (index, column) in columns.indexed)
            SizedBox(
              width:
                  column.width + (index == columns.length - 1 ? extraWidth : 0),
              child: Align(
                alignment: column.alignEnd
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: cells[index],
              ),
            ),
        ],
      ),
    );
  }

  Widget _tappable(int index, Widget row) {
    final onTap = onRowTap;
    if (onTap == null) return row;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(onTap: () => onTap(index), child: row),
    );
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = AppTextStyles.tableFootnote.copyWith(
      color: context.appColors.textSecondary,
      fontWeight: FontWeight.w500,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = _contentWidth;
        final extraWidth = constraints.maxWidth > contentWidth
            ? constraints.maxWidth - contentWidth
            : 0.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: contentWidth + extraWidth,
            child: Column(
              children: [
                Container(
                  height: _headerHeight,
                  decoration: const BoxDecoration(
                    color: AppColors.tableHeaderBackground,
                    border: Border(
                      bottom: BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                  child: _row([
                    for (final column in columns)
                      Text(column.label, style: headerStyle),
                  ], extraWidth),
                ),
                for (final (index, cells) in rows.indexed)
                  _tappable(
                    index,
                    Container(
                      constraints: const BoxConstraints(minHeight: _rowHeight),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.cardBorder),
                        ),
                      ),
                      child: _row(cells, extraWidth),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
