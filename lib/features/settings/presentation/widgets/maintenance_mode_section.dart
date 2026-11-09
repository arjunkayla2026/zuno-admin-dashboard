import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_state.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/maintenance_flow.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/maintenance_mode_card.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/maintenance_mode_note.dart';

class MaintenanceModeSection extends StatelessWidget {
  const MaintenanceModeSection({super.key});

  static const double _noteWidth = 290;
  static const double _gap = 22;
  static const double _stackBreakpoint = 760;
  static const EdgeInsets _padding = EdgeInsets.all(22);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding,
      child: BlocSelector<SettingsCubit, SettingsState, bool>(
        selector: (state) => state.maintenanceEnabled,
        builder: (context, enabled) {
          final card = MaintenanceModeCard(
            enabled: enabled,
            onChanged: (value) => toggleMaintenance(context, value),
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < _stackBreakpoint) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    card,
                    const SizedBox(height: _gap),
                    const MaintenanceModeNote(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: card),
                  const SizedBox(width: _gap),
                  const SizedBox(
                    width: _noteWidth,
                    child: MaintenanceModeNote(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
