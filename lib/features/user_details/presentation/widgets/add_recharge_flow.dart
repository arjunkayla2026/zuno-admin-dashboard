import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_success_dialog.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';
import 'package:zuno_admin_dashboard/features/user_details/data/models/recharge_package.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/add_recharge_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_recharge_history_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/add_recharge_dialog.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/confirm_recharge_dialog.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

Future<void> startAddRecharge(BuildContext context, AdminUser user) async {
  final details = context.read<UserDetailsCubit>();
  final history = context.read<UserRechargeHistoryCubit>();
  final recharge = context.read<AddRechargeCubit>();
  unawaited(recharge.loadPackages());

  final package = await showAppDialog<RechargePackage>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: recharge,
      child: AddRechargeDialog(user: user),
    ),
  );
  if (package == null || !context.mounted) return;

  final result = await showAppDialog<AdminRechargeResult>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: recharge,
      child: ConfirmRechargeDialog(user: user, package: package),
    ),
  );
  if (result == null || !context.mounted) return;

  details.applyWalletBalance(result.walletBalance);
  unawaited(details.loadRechargeSummary());
  unawaited(history.reload());

  await showAppSuccessDialog(
    context: context,
    title: AppStrings.rechargeAdded,
    message: AppStrings.coinsAddedToWallet(
      NumberFormatter.grouped(result.coins),
      user.name,
    ),
    actionLabel: AppStrings.done,
  );
}
