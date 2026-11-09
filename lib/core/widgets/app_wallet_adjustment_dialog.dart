import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zuno_admin_dashboard/core/enums/wallet_adjustment_type.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_segmented_control.dart';

class WalletAdjustment {
  const WalletAdjustment({
    required this.type,
    required this.amount,
    required this.description,
  });

  final WalletAdjustmentType type;
  final int amount;
  final String description;
}

Future<WalletAdjustment?> showWalletAdjustmentDialog({
  required BuildContext context,
  required int walletBalance,
}) {
  return showAppDialog<WalletAdjustment>(
    context: context,
    builder: (_) => AppWalletAdjustmentDialog(walletBalance: walletBalance),
  );
}

class AppWalletAdjustmentDialog extends StatefulWidget {
  const AppWalletAdjustmentDialog({super.key, required this.walletBalance});

  final int walletBalance;

  @override
  State<AppWalletAdjustmentDialog> createState() =>
      _AppWalletAdjustmentDialogState();
}

class _AppWalletAdjustmentDialogState extends State<AppWalletAdjustmentDialog> {
  static const double _segmentWidth = 124;
  static const double _toggleGap = 18;
  static const double _fieldGap = 14;
  static const double _actionsGap = 10;
  static const double _actionSpacing = 8;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(16, 18, 16, 18);

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  WalletAdjustmentType _type = WalletAdjustmentType.credit;
  bool _submitted = false;

  int get _amount => int.tryParse(_amountController.text) ?? 0;

  bool get _exceedsBalance =>
      _type == WalletAdjustmentType.debit && _amount > widget.walletBalance;

  String? get _amountError {
    if (_exceedsBalance) {
      return AppStrings.debitExceedsBalance(
        NumberFormatter.rupees(widget.walletBalance),
      );
    }
    if (_submitted && _amount <= 0) return AppStrings.enterAmount;
    return null;
  }

  void _onChanged(String _) => setState(() {});

  void _save() {
    if (_amount <= 0 || _exceedsBalance) {
      setState(() => _submitted = true);
      return;
    }
    Navigator.of(context).pop(
      WalletAdjustment(
        type: _type,
        amount: _amount,
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogSurface(
      padding: _padding,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: AppSegmentedControl<WalletAdjustmentType>(
                options: const {
                  WalletAdjustmentType.credit: AppStrings.credit,
                  WalletAdjustmentType.debit: AppStrings.debit,
                },
                value: _type,
                segmentWidth: _segmentWidth,
                onChanged: (type) => setState(() => _type = type),
              ),
            ),
            const SizedBox(height: _toggleGap),
            AppLabeledTextField(
              label: AppStrings.amount,
              hint: AppStrings.typeHint,
              controller: _amountController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: _onChanged,
              errorText: _amountError,
            ),
            const SizedBox(height: _fieldGap),
            AppLabeledTextField(
              label: AppStrings.description,
              hint: AppStrings.typeHint,
              controller: _descriptionController,
              textInputAction: TextInputAction.done,
              onChanged: _onChanged,
            ),
            const SizedBox(height: _actionsGap),
            Row(
              children: [
                Expanded(
                  child: AppPrimaryButton(
                    label: AppStrings.cancel,
                    tonal: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: _actionSpacing),
                Expanded(
                  child: AppPrimaryButton(
                    label: AppStrings.save,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
