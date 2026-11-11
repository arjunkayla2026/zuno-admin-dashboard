import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/state/surge_sessions_cubit.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/state/surge_sessions_state.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/widgets/surge_sessions_table.dart';

class SurgeSessionsTableCard extends StatelessWidget {
  const SurgeSessionsTableCard({super.key});

  static const double _emptyHeight = 140;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SurgeSessionsCubit, SurgeSessionsState>(
      builder: (context, state) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.status == LoadStatus.loading)
                const AppTableLoadingState()
              else if (state.status == LoadStatus.failure)
                AppTableErrorState(
                  message: state.errorMessage ?? AppStrings.recordsLoadFailed,
                  onRetry: context.read<SurgeSessionsCubit>().load,
                )
              else
                SurgeSessionsTable(sessions: state.sessions),
              if (state.status == LoadStatus.loaded && state.sessions.isEmpty)
                SizedBox(
                  height: _emptyHeight,
                  child: Center(
                    child: Text(
                      AppStrings.noSurgeSessions,
                      style: AppTextStyles.tableCell.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
