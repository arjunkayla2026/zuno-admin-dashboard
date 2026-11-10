import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/decimal_input_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_error_banner.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_field_row.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_read_only_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_section_label.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_status.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/package_switch_tile.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/package_preview_card.dart';

class PackageSheet extends StatefulWidget {
  const PackageSheet({super.key, this.plan, required this.onSave});

  final PackagePlan? plan;
  final Future<String?> Function(PackagePlan plan) onSave;

  @override
  State<PackageSheet> createState() => _PackageSheetState();
}

class _PackageSheetState extends State<PackageSheet> {
  static const double _fieldGap = 14;
  static const double _helperGap = 6;
  static const double _previewTopGap = 40;
  static const double _previewGap = 10;
  static const TextInputType _decimalKeyboard = TextInputType.numberWithOptions(
    decimal: true,
  );

  final _amountFormatter = DecimalInputFormatter();
  late bool _gst = widget.plan?.isGstEnabled ?? true;
  late bool _active = widget.plan?.isActive ?? true;
  late final _payableController = TextEditingController(
    text: _initial(widget.plan?.rechargeAmount),
  );
  late final _receivableController = TextEditingController(
    text: _initial(widget.plan?.receivableAmount),
  );
  late final _offerTagController = TextEditingController(
    text: widget.plan?.offerTag ?? '',
  );
  late final _offerPercentageController = TextEditingController(
    text: switch (widget.plan) {
      final plan? when plan.hasOfferPercentage => NumberFormatter.trimmedAmount(
        plan.offerPercentage,
      ),
      _ => '',
    },
  );
  late PackagePreview? _preview = switch (widget.plan) {
    final plan? => (
      price: plan.rechargeAmount,
      coins: plan.coins,
      offerTag: plan.offerTag,
    ),
    null => null,
  };
  bool _submitted = false;
  bool _saving = false;
  String? _errorMessage;

  static String _initial(double? value) =>
      value == null ? '' : NumberFormatter.amountInput(value);

  static double _parse(TextEditingController controller) =>
      NumberFormatter.tryParseAmount(controller.text) ?? 0;

  int get _coins => PackagePlan.coinsFor(_parse(_receivableController));

  List<TextEditingController> get _controllers => [
    _payableController,
    _receivableController,
    _offerTagController,
    _offerPercentageController,
  ];

  String? _error(TextEditingController controller) =>
      _submitted && _parse(controller) <= 0 ? AppStrings.enterValue : null;

  String? get _offerPercentageError =>
      _submitted &&
          _parse(_offerPercentageController) > PackagePlan.maxOfferPercentage
      ? AppStrings.offerPercentageTooHigh
      : null;

  void _onPayableChanged(String value) {
    final payable = NumberFormatter.tryParseAmount(value);
    setState(() {
      _receivableController.text = payable == null
          ? ''
          : NumberFormatter.amountInput(
              PackagePlan.receivableFor(payable, gst: _gst),
            );
    });
  }

  void _onReceivableChanged(String value) {
    final receivable = NumberFormatter.tryParseAmount(value);
    setState(() {
      _payableController.text = receivable == null
          ? ''
          : NumberFormatter.amountInput(
              PackagePlan.payableFor(receivable, gst: _gst),
            );
    });
  }

  void _onGstChanged(bool enabled) {
    setState(() => _gst = enabled);
    _onPayableChanged(_payableController.text);
  }

  void _refreshPreview() {
    setState(
      () => _preview = (
        price: _parse(_payableController),
        coins: _coins,
        offerTag: _offerTagController.text,
      ),
    );
  }

  Future<void> _save() async {
    final payable = _parse(_payableController);
    final receivable = _parse(_receivableController);
    final offerPercentage = _parse(_offerPercentageController);
    if (payable <= 0 ||
        receivable <= 0 ||
        offerPercentage > PackagePlan.maxOfferPercentage) {
      setState(() => _submitted = true);
      return;
    }
    final plan = PackagePlan(
      id: widget.plan?.id ?? '',
      rechargeAmount: payable,
      receivableAmount: receivable,
      coins: PackagePlan.coinsFor(receivable),
      offerTag: _offerTagController.text.trim(),
      offerPercentage: offerPercentage,
      status: _active ? PackageStatus.active : PackageStatus.inactive,
      isGstEnabled: _gst,
      createdAt: widget.plan?.createdAt,
      updatedAt: widget.plan?.updatedAt,
    );
    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final error = await widget.onSave(plan);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(plan);
      return;
    }
    setState(() {
      _saving = false;
      _errorMessage = error;
    });
  }

  Widget _amountField(
    String label,
    TextEditingController controller, {
    required ValueChanged<String> onChanged,
  }) {
    return AppLabeledTextField(
      label: label,
      hint: label,
      controller: controller,
      keyboardType: _decimalKeyboard,
      inputFormatters: [_amountFormatter],
      onChanged: onChanged,
      errorText: _error(controller),
      dense: true,
    );
  }

  Widget _textField(String label, TextEditingController controller) {
    return AppLabeledTextField(
      label: label,
      hint: label,
      controller: controller,
      dense: true,
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;

    return AppSideSheet(
      title: plan == null
          ? AppStrings.addPackageTitle
          : AppStrings.editPackageTitle,
      subtitle: plan == null
          ? AppStrings.packageSheetSubtitle
          : AppStrings.packagePriceAndCoins(
              NumberFormatter.rupeesAmount(plan.rechargeAmount),
              NumberFormatter.grouped(plan.coins),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PackageSwitchTile(
            title: AppStrings.packageActiveTitle,
            helper: AppStrings.packageActiveHelper,
            value: _active,
            onChanged: (active) => setState(() => _active = active),
          ),
          const SizedBox(height: _fieldGap),
          if (plan == null) ...[
            PackageSwitchTile(
              title: AppStrings.gstToggleTitle,
              helper: AppStrings.gstToggleHelper,
              value: _gst,
              onChanged: _onGstChanged,
            ),
            const SizedBox(height: _fieldGap),
          ],
          AppFieldRow(
            first: _amountField(
              AppStrings.payableAmountField,
              _payableController,
              onChanged: _onPayableChanged,
            ),
            second: _amountField(
              AppStrings.receivableAmountField,
              _receivableController,
              onChanged: _onReceivableChanged,
            ),
          ),
          const SizedBox(height: _fieldGap),
          AppReadOnlyField(
            label: AppStrings.receivableCoin,
            value: NumberFormatter.grouped(_coins),
          ),
          const SizedBox(height: _fieldGap),
          AppFieldRow(
            first: _textField(AppStrings.offerTag, _offerTagController),
            second: AppLabeledTextField(
              label: AppStrings.offerPercentageField,
              hint: AppStrings.offerPercentageField,
              controller: _offerPercentageController,
              keyboardType: _decimalKeyboard,
              inputFormatters: [_amountFormatter],
              errorText: _offerPercentageError,
              dense: true,
            ),
          ),
          const SizedBox(height: _helperGap),
          Text(
            AppStrings.offerHelper,
            style: AppTextStyles.captionSmall.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: _previewTopGap),
          const AppSectionLabel(AppStrings.preview),
          const SizedBox(height: _previewGap),
          Align(
            alignment: Alignment.centerLeft,
            child: PackagePreviewCard(preview: _preview),
          ),
          const SizedBox(height: _previewGap),
          Align(
            alignment: Alignment.centerLeft,
            child: AppSecondaryButton(
              label: AppStrings.refreshPreview,
              small: true,
              onPressed: _refreshPreview,
            ),
          ),
          if (_errorMessage case final message?) ...[
            const SizedBox(height: _fieldGap),
            AppErrorBanner(message: message),
          ],
        ],
      ),
      footer: Wrap(
        spacing: AppUtils.spacingSm,
        runSpacing: AppUtils.spacingSm,
        children: [
          AppSecondaryButton(
            label: AppStrings.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppPrimaryButton(
            label: _saving ? AppStrings.saving : AppStrings.savePackage,
            compact: true,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
