import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_success_dialog.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/state/packages_cubit.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/package_sheet.dart';

Future<void> openPackageSheet(BuildContext context, {PackagePlan? plan}) async {
  final cubit = context.read<PackagesCubit>();
  final saved = await showAppSideSheet<PackagePlan>(
    context: context,
    builder: (_) => PackageSheet(plan: plan),
  );
  if (saved == null) return;
  if (plan == null) {
    cubit.addPackage(saved);
    return;
  }

  cubit.updatePackage(saved);
  if (!context.mounted) return;
  await showAppSuccessDialog(
    context: context,
    title: AppStrings.packageUpdated,
    message: AppStrings.packageSaved(
      NumberFormatter.rupees(saved.payableAmount),
      NumberFormatter.grouped(saved.coins),
    ),
    actionLabel: AppStrings.done,
  );
}
