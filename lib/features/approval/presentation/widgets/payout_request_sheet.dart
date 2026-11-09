import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_detail_grid.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_section_label.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/payout_request.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/payout_request_header.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/payout_request_labels.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/mock/host_mock_data.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_details_arguments.dart';

class PayoutRequestSheet extends StatelessWidget {
  const PayoutRequestSheet({
    super.key,
    required this.payout,
    required this.onChanged,
  });

  static const double _headerGap = 20;
  static const double _labelGap = 12;
  static const double _sectionGap = 22;
  static const double _footerGap = 10;
  static const int _basicInfoColumns = 3;

  final PayoutRequest payout;
  final ValueChanged<PayoutRequest> onChanged;

  AdminHost? get _host {
    for (final host in HostMockData.hosts) {
      if (host.hostId == payout.hostId) return host;
    }
    return null;
  }

  void _viewHost(BuildContext context, AdminHost host) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushNamed(
      AppRoutes.hostDetails,
      arguments: HostDetailsArguments(host: host),
    );
  }

  Future<void> _decide(BuildContext context, {required bool accept}) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      icon: accept ? Icons.check_circle_outline_rounded : Icons.close_rounded,
      title: accept
          ? AppStrings.acceptPayoutTitle
          : AppStrings.rejectPayoutTitle,
      message: TextSpan(
        text: accept
            ? AppStrings.acceptPayoutMessage(
                payout.hostName,
                payout.accountLastDigits,
              )
            : AppStrings.rejectPayoutMessage(payout.hostName),
      ),
      confirmLabel: accept ? AppStrings.accept : AppStrings.reject,
      positive: accept,
    );
    if (!confirmed || !context.mounted) return;
    onChanged(
      payout.copyWith(
        status: accept
            ? PayoutRequestStatus.accepted
            : PayoutRequestStatus.rejected,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final host = _host;

    return AppSideSheet(
      title: AppStrings.payoutReviewTitle,
      subtitle: AppStrings.hostRequestSubtitle(
        payout.payoutId,
        DateFormatter.short(payout.submittedOn),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PayoutRequestHeader(payout: payout),
          const SizedBox(height: _headerGap),
          const AppSectionLabel(AppStrings.hostBasicInfo),
          const SizedBox(height: _labelGap),
          AppDetailGrid(
            columns: _basicInfoColumns,
            items: [
              AppDetailItem(AppStrings.hostName, value: payout.hostName),
              AppDetailItem(
                AppStrings.hostId,
                value: payout.hostId,
                mono: true,
              ),
              AppDetailItem(AppStrings.realNameField, value: payout.realName),
              AppDetailItem(AppStrings.mobileNumberField, value: payout.phone),
              AppDetailItem(AppStrings.location, value: payout.location),
              AppDetailItem(
                AppStrings.status,
                value: PayoutRequestLabels.hostStatus(payout.hostStatus),
              ),
            ],
          ),
          const SizedBox(height: _sectionGap),
          const AppSectionLabel(AppStrings.bankAccount),
          const SizedBox(height: _labelGap),
          AppDetailGrid(
            items: [
              AppDetailItem(
                AppStrings.accountHolderNameField,
                value: payout.accountHolderName,
              ),
              AppDetailItem(AppStrings.branchName, value: payout.branchName),
              AppDetailItem(
                AppStrings.accountNumber,
                value: payout.accountNumber,
                mono: true,
              ),
              AppDetailItem(
                AppStrings.ifscCode,
                value: payout.ifscCode,
                mono: true,
              ),
            ],
          ),
        ],
      ),
      footer: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: AppUtils.spacingSm,
          children: [
            AppSecondaryButton(
              label: AppStrings.viewHost,
              onPressed: host == null ? null : () => _viewHost(context, host),
            ),
            if (payout.isPending)
              Wrap(
                spacing: _footerGap,
                runSpacing: AppUtils.spacingSm,
                children: [
                  AppSecondaryButton(
                    label: AppStrings.reject,
                    destructive: true,
                    onPressed: () => _decide(context, accept: false),
                  ),
                  AppPrimaryButton(
                    label: AppStrings.accept,
                    icon: Icons.check_rounded,
                    compact: true,
                    positive: true,
                    onPressed: () => _decide(context, accept: true),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
