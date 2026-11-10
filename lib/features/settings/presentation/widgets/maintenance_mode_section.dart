import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_error_banner.dart';
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
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) =>
            previous.maintenanceEnabled != current.maintenanceEnabled ||
            previous.maintenanceStatus != current.maintenanceStatus ||
            previous.maintenanceSaving != current.maintenanceSaving,
        builder: (context, state) {
          final editable =
              state.maintenanceStatus == LoadStatus.loaded &&
              !state.maintenanceSaving;
          final error = state.maintenanceStatus == LoadStatus.failure
              ? state.maintenanceError
              : null;
          final toggle = MaintenanceModeCard(
            enabled: state.maintenanceEnabled,
            onChanged: editable
                ? (value) => toggleMaintenance(context, value)
                : null,
          );
          final card = error == null
              ? toggle
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppErrorBanner(message: error),
                    const SizedBox(height: _gap),
                    toggle,
                  ],
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
