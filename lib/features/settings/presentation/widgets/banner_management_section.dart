import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_state.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/banner_grid.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/banner_toolbar.dart';

class BannerManagementSection extends StatelessWidget {
  const BannerManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SettingsCubit, SettingsState, List<BannerImage>>(
      selector: (state) => state.banners,
      builder: (context, banners) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BannerToolbar(bannerCount: banners.length),
            const Divider(color: AppColors.cardBorder),
            BannerGrid(banners: banners),
          ],
        );
      },
    );
  }
}
