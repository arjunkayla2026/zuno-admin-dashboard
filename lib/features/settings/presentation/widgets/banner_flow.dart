import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/add_banner_dialog.dart';

Future<void> openAddBannerDialog(BuildContext context) async {
  final cubit = context.read<SettingsCubit>();
  await showAppDialog<void>(
    context: context,
    builder: (_) => AddBannerDialog(onSubmit: cubit.addBanner),
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
        const TextSpan(text: AppStrings.deleteBannerMessageTail),
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
