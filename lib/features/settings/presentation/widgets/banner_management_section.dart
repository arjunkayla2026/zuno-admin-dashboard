import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_state.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/banner_grid.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/banner_toolbar.dart';

class BannerManagementSection extends StatelessWidget {
  const BannerManagementSection({super.key});

  Widget _body(BuildContext context, SettingsState state) {
    return switch (state.bannersStatus) {
      LoadStatus.loading => const AppTableLoadingState(),
      LoadStatus.failure => AppTableErrorState(
        message: state.bannersError ?? AppStrings.recordsLoadFailed,
        onRetry: context.read<SettingsCubit>().loadBanners,
      ),
      LoadStatus.loaded => BannerGrid(banners: state.banners),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.banners != current.banners ||
          previous.bannersStatus != current.bannersStatus ||
          previous.bannersError != current.bannersError,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BannerToolbar(banners: state.banners),
            const Divider(color: AppColors.cardBorder),
            _body(context, state),
          ],
        );
      },
    );
  }
}
