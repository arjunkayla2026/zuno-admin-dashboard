import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_options_menu.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/add_banner_dialog.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/banner_labels.dart';

Future<void> openAddBannerDialog(BuildContext anchorContext) async {
  final cubit = anchorContext.read<SettingsCubit>();
  final screen = await showAppOptionsMenu<BannerScreen>(
    anchorContext: anchorContext,
    options: BannerScreen.values,
    labelOf: BannerLabels.option,
  );
  if (screen == null || !anchorContext.mounted) return;

  await showAppDialog<void>(
    context: anchorContext,
    builder: (_) => AddBannerDialog(screen: screen, onSubmit: cubit.addBanner),
  );
}

Future<void> confirmDeleteBanner(
  BuildContext context,
  BannerImage banner,
) async {
  final cubit = context.read<SettingsCubit>();
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showAppConfirmDialog(
    context: context,
    icon: Icons.delete_outline_rounded,
    title: AppStrings.deleteBannerTitle,
    message: TextSpan(
      children: [
        TextSpan(
          text: banner.imageName,
          style: TextStyle(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextSpan(
          text: AppStrings.deleteBannerMessageTail(
            BannerLabels.screen(banner.screen),
          ),
        ),
      ],
    ),
    confirmLabel: AppStrings.deleteBannerAction,
    centerTitle: true,
  );
  if (!confirmed) return;

  final error = await cubit.deleteBanner(banner);
  if (error != null) {
    messenger.showSnackBar(SnackBar(content: Text(error)));
  }
}
