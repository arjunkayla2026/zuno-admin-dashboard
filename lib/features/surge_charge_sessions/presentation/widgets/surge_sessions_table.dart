import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_action_menu.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_data_table.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_switch.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_take_action_button.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/data/models/surge_session.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/state/surge_sessions_cubit.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/widgets/surge_label_pill.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/widgets/surge_session_flow.dart';

class SurgeSessionsTable extends StatelessWidget {
  const SurgeSessionsTable({super.key, required this.sessions});

  static const List<AppTableColumn> _columns = [
    AppTableColumn(AppStrings.session, 130),
    AppTableColumn(AppStrings.startTime, 128),
    AppTableColumn(AppStrings.endTime, 120),
    AppTableColumn(AppStrings.surgeCharge, 134, alignEnd: true),
    AppTableColumn('', 28),
    AppTableColumn(AppStrings.shownToUsersBeforeCall, 352),
    AppTableColumn(AppStrings.status, 239),
    AppTableColumn(AppStrings.actions, 120),
  ];
  static const List<AppMenuAction> _menuActions = [
    AppMenuAction.edit,
    AppMenuAction.delete,
  ];

  final List<SurgeSession> sessions;

  static String _time(int? minutes) => minutes == null
      ? AppStrings.emptyValue
      : DateFormatter.minutesOfDay(minutes);

  @override
  Widget build(BuildContext context) {
    final canEdit = context.select(
      (SurgeSessionsCubit cubit) => cubit.state.canEdit,
    );
    final textColor = context.colorScheme.onSurface;
    final cell = AppTextStyles.bodySmall.copyWith(color: textColor);
    final strong = cell.copyWith(fontWeight: FontWeight.w700);

    return AppDataTable(
      columns: _columns,
      rows: [
        for (final session in sessions)
          [
            Text(session.name, style: strong),
            Text(_time(session.startMinutes), style: cell),
            Text(_time(session.endMinutes), style: cell),
            Text(AppStrings.surgePercent(session.percent), style: strong),
            const SizedBox.shrink(),
            SurgeLabelPill(percent: session.percent),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppStatusSwitch(
                  value: session.enabled,
                  onChanged: canEdit
                      ? (enabled) =>
                            setSurgeSessionEnabled(context, session, enabled)
                      : null,
                ),
                const SizedBox(width: AppUtils.spacingSm),
                AppStatusBadge(
                  label: session.enabled
                      ? AppStrings.enabled
                      : AppStrings.disabled,
                  status: session.enabled
                      ? AppStatus.active
                      : AppStatus.inactive,
                ),
              ],
            ),
            AppTakeActionButton(
              actions: _menuActions,
              onSelected: (action) => !canEdit
                  ? null
                  : switch (action) {
                      AppMenuAction.edit => editSurgeSession(context, session),
                      AppMenuAction.delete => removeSurgeSession(
                        context,
                        session,
                      ),
                      AppMenuAction.block || AppMenuAction.unblock => null,
                    },
            ),
          ],
      ],
    );
  }
}
