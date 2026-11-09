import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';
import 'package:zuno_admin_dashboard/features/settings/data/mock/settings_mock_data.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/add_banner_dialog.dart';

Future<void> openAddBannerDialog(BuildContext context) async {
  final cubit = context.read<SettingsCubit>();
  final audience = await showAppDialog<BannerAudience>(
    context: context,
    builder: (_) =>
        AddBannerDialog(fileName: SettingsMockData.sampleBanner.fileName),
  );
  if (audience != null) cubit.addBanner(audience);
}

Future<void> confirmDeleteBanner(
  BuildContext context,
  int index,
  BannerImage banner,
) async {
  final cubit = context.read<SettingsCubit>();
  final confirmed = await showAppConfirmDialog(
    context: context,
    icon: Icons.delete_outline_rounded,
    title: AppStrings.deleteBannerTitle,
    message: TextSpan(
      children: [
        TextSpan(
          text: banner.fileName,
          style: TextStyle(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const TextSpan(text: AppStrings.deleteBannerMessageTail),
      ],
    ),
    confirmLabel: AppStrings.deleteBannerAction,
    centerTitle: true,
  );
  if (confirmed) cubit.deleteBannerAt(index);
}
