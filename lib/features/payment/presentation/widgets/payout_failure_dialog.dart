import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_header.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_dropdown_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_failure_reason.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/widgets/withdrawal_labels.dart';

Future<PayoutFailureInput?> showPayoutFailureDialog({
  required BuildContext context,
  required String title,
  required String message,
}) {
  return showAppDialog<PayoutFailureInput>(
    context: context,
    builder: (_) => PayoutFailureDialog(title: title, message: message),
  );
}

class PayoutFailureDialog extends StatefulWidget {
  const PayoutFailureDialog({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  State<PayoutFailureDialog> createState() => _PayoutFailureDialogState();
}

class _PayoutFailureDialogState extends State<PayoutFailureDialog> {
  static const double _messageGap = 16;
  static const double _fieldGap = 14;
  static const double _actionsGap = 22;
  static const double _actionSpacing = 10;
  static const int _noteLines = 3;
  static const EdgeInsets _padding = EdgeInsets.all(AppUtils.spacingXl);

  final _noteController = TextEditingController();
  PayoutFailureReason? _reason;
  bool _submitted = false;

  String? get _note {
    final note = _noteController.text.trim();
    return note.isEmpty ? null : note;
  }

  String? get _reasonError =>
      _submitted && _reason == null ? AppStrings.selectReason : null;

  String? get _noteError =>
      _submitted && _reason?.needsNote == true && _note == null
      ? AppStrings.failureNoteRequired
      : null;

  void _submit() {
    final reason = _reason;
    if (reason == null || (reason.needsNote && _note == null)) {
      setState(() => _submitted = true);
      return;
    }
    Navigator.of(context).pop(PayoutFailureInput(reason: reason, note: _note));
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final reasonError = _reasonError;

    return AppDialogSurface(
      padding: _padding,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDialogHeader(
              icon: SvgPicture.asset(
                AppImages.paymentIcon,
                width: AppDialogHeader.iconSize,
                height: AppDialogHeader.iconSize,
                colorFilter: ColorFilter.mode(
                  colors.errorText,
                  BlendMode.srcIn,
                ),
              ),
              title: widget.title,
            ),
            const SizedBox(height: _messageGap),
            Text(
              widget.message,
              style: AppTextStyles.tableCell.copyWith(
                color: AppColors.dialogMessage,
              ),
            ),
            const SizedBox(height: _fieldGap),
            AppLabeledDropdownField<PayoutFailureReason>(
              label: AppStrings.failureReason,
              hint: AppStrings.selectReason,
              value: _reason,
              options: PayoutFailureReason.values,
              labelOf: WithdrawalLabels.failureReason,
              onChanged: (reason) => setState(() => _reason = reason),
            ),
            if (reasonError != null)
              Padding(
                padding: const EdgeInsets.only(top: AppUtils.spacingXs),
                child: Text(
                  reasonError,
                  style: AppTextStyles.tableFootnote.copyWith(
                    color: colors.errorText,
                  ),
                ),
              ),
            const SizedBox(height: _fieldGap),
            AppLabeledTextField(
              label: AppStrings.failureNote,
              hint: AppStrings.failureNoteHint,
              controller: _noteController,
              maxLines: _noteLines,
              minLines: 1,
              inputFormatters: [
                LengthLimitingTextInputFormatter(
                  PayoutFailureInput.maxNoteLength,
                ),
              ],
              onChanged: (_) => setState(() {}),
              errorText: _noteError,
            ),
            const SizedBox(height: _actionsGap),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: _actionSpacing,
              runSpacing: AppUtils.spacingSm,
              children: [
                AppSecondaryButton(
                  label: AppStrings.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                AppPrimaryButton(
                  label: AppStrings.markAsFailed,
                  compact: true,
                  destructive: true,
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
