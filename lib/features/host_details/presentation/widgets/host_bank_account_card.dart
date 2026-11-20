import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/enums/app_status.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_meta_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_section_card.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_badge.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_success_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/bank_account_record.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/edit_bank_account_sheet.dart';

class HostBankAccountCard extends StatelessWidget {
  const HostBankAccountCard({super.key});

  static const double _loaderHeight = 76;
  static const double _editIconSize = 14;
  static const double _editIconGap = 6;
  static const double _fieldSpacing = 28;
  static const double _nameMinWidth = 150;
  static const double _codeMinWidth = 120;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(20, 16, 20, 18);

  static (String, AppStatus)? _status(String? status) => switch (status) {
    UserRecord.documentApproved => (AppStrings.approved, AppStatus.active),
    UserRecord.documentSubmitted => (AppStrings.pending, AppStatus.pending),
    UserRecord.documentRejected => (AppStrings.rejected, AppStatus.error),
    _ => null,
  };

  Future<void> _edit(BuildContext context) async {
    final cubit = context.read<HostDetailsCubit>();
    final account = cubit.state.bankAccount;
    if (account == null) return;
    final host = cubit.state.host;

    final saved = await showAppSideSheet<bool>(
      context: context,
      builder: (_) => EditBankAccountSheet(
        host: host,
        account: account,
        onSave: cubit.saveBankAccount,
      ),
    );
    if (saved != true || !context.mounted) return;

    await showAppSuccessDialog(
      context: context,
      title: AppStrings.bankAccountUpdated,
      message: AppStrings.bankAccountSaved(host.name),
      actionLabel: AppStrings.done,
    );
  }

  Widget _details(BankAccountRecord account) {
    AppMetaField field(
      String label,
      String? value, {
      double minWidth = _codeMinWidth,
      bool mono = false,
    }) => AppMetaField(
      label: label,
      value: value == null || value.isEmpty ? AppStrings.emptyValue : value,
      minWidth: minWidth,
      mono: mono,
    );

    return Wrap(
      spacing: _fieldSpacing,
      runSpacing: AppUtils.spacingSm,
      children: [
        field(
          AppStrings.accountHolderNameField,
          account.accountHolderName,
          minWidth: _nameMinWidth,
        ),
        field(
          AppStrings.branchName,
          account.branchName,
          minWidth: _nameMinWidth,
        ),
        field(AppStrings.accountNumber, account.accountNumber, mono: true),
        field(AppStrings.ifscCode, account.ifscCode, mono: true),
        field(AppStrings.panNumber, account.panNumber, mono: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final (account, loadStatus, error, canEdit) = context.select(
      (HostDetailsCubit cubit) => (
        cubit.state.bankAccount,
        cubit.state.bankAccountStatus,
        cubit.state.bankAccountError,
        cubit.state.host.hasActions,
      ),
    );
    final badge = _status(account?.status);

    return AppSectionCard(
      title: AppStrings.bankAccountDetails,
      trailing: account == null
          ? null
          : Wrap(
              spacing: AppUtils.spacingMd,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (badge case (final label, final status))
                  AppStatusBadge(label: label, status: status),
                if (canEdit)
                  AppSecondaryButton(
                    label: AppStrings.edit,
                    small: true,
                    leading: const Icon(
                      Icons.edit_outlined,
                      size: _editIconSize,
                    ),
                    leadingGap: _editIconGap,
                    onPressed: () => _edit(context),
                  ),
              ],
            ),
      child: switch ((loadStatus, account)) {
        (LoadStatus.loading, _) => const AppTableLoadingState(
          height: _loaderHeight,
        ),
        (LoadStatus.failure, _) => AppTableErrorState(
          message: error ?? AppStrings.recordsLoadFailed,
          onRetry: context.read<HostDetailsCubit>().retryBankAccount,
        ),
        (LoadStatus.loaded, final loaded?) => Padding(
          padding: _padding,
          child: _details(loaded),
        ),
        (LoadStatus.loaded, null) => Padding(
          padding: _padding,
          child: Text(
            AppStrings.bankAccountMissing,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ),
      },
    );
  }
}
