import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_success_dialog.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/models/recharge_package.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/add_recharge_dialog.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/confirm_recharge_dialog.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

Future<void> startAddRecharge(BuildContext context, AdminUser user) async {
  final cubit = context.read<UserDetailsCubit>();

  final package = await showAppDialog<RechargePackage>(
    context: context,
    builder: (_) => AddRechargeDialog(user: user),
  );
  if (package == null || !context.mounted) return;

  final confirmed = await showAppDialog<bool>(
    context: context,
    builder: (_) => ConfirmRechargeDialog(user: user, package: package),
  );
  if (confirmed != true || !context.mounted) return;

  cubit.addRecharge(package);

  await showAppSuccessDialog(
    context: context,
    title: AppStrings.rechargeAdded,
    message: AppStrings.coinsAddedToWallet(
      NumberFormatter.grouped(package.totalCoins),
      user.name,
    ),
    actionLabel: AppStrings.done,
  );
}
