import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_detail_grid.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_error_banner.dart';
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

class PayoutRequestSheet extends StatefulWidget {
  const PayoutRequestSheet({
    super.key,
    required this.payout,
    required this.onDecide,
  });

  final PayoutRequest payout;
  final Future<String?> Function(PayoutRequest, PayoutRequestStatus) onDecide;

  @override
  State<PayoutRequestSheet> createState() => _PayoutRequestSheetState();
}

class _PayoutRequestSheetState extends State<PayoutRequestSheet> {
  static const double _headerGap = 20;
  static const double _labelGap = 12;
  static const double _sectionGap = 22;
  static const double _footerGap = 10;
  static const int _basicInfoColumns = 3;

  bool _isSaving = false;
  String? _error;

  PayoutRequest get _payout => widget.payout;

  AdminHost? get _host {
    for (final host in HostMockData.hosts) {
      if (host.hostId == _payout.hostId) return host;
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

  Future<void> _decide({required bool accept}) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      icon: accept ? Icons.check_circle_outline_rounded : Icons.close_rounded,
      title: accept
          ? AppStrings.acceptPayoutTitle
          : AppStrings.rejectPayoutTitle,
      message: TextSpan(
        text: accept
            ? AppStrings.acceptPayoutMessage(
                _payout.hostName,
                _payout.accountLastDigits,
              )
            : AppStrings.rejectPayoutMessage(_payout.hostName),
      ),
      confirmLabel: accept ? AppStrings.accept : AppStrings.reject,
      positive: accept,
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });
    final error = await widget.onDecide(
      _payout,
      accept ? PayoutRequestStatus.accepted : PayoutRequestStatus.rejected,
    );
    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isSaving = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final host = _host;
    final payout = _payout;

    return AppSideSheet(
      title: AppStrings.payoutReviewTitle,
      subtitle: AppStrings.hostRequestSubtitle(
        payout.userID,
        DateFormatter.short(payout.submittedOn),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error case final error?) ...[
            AppErrorBanner(message: error),
            const SizedBox(height: _labelGap),
          ],
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
                value: payout.userID,
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
                    onPressed: _isSaving ? null : () => _decide(accept: false),
                  ),
                  AppPrimaryButton(
                    label: AppStrings.accept,
                    icon: Icons.check_rounded,
                    compact: true,
                    positive: true,
                    onPressed: _isSaving ? null : () => _decide(accept: true),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
