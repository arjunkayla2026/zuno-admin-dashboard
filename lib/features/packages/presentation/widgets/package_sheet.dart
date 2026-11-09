import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_field_row.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_section_label.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/package_gst_toggle.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/widgets/package_preview_card.dart';

class PackageSheet extends StatefulWidget {
  const PackageSheet({super.key, this.plan});

  final PackagePlan? plan;

  @override
  State<PackageSheet> createState() => _PackageSheetState();
}

class _PackageSheetState extends State<PackageSheet> {
  static const double _fieldGap = 14;
  static const double _helperGap = 6;
  static const double _previewTopGap = 40;
  static const double _previewGap = 10;

  late bool _gst = widget.plan?.gstEnabled ?? true;
  late final _payableController = TextEditingController(
    text: _initial(widget.plan?.payableAmount),
  );
  late final _receivableController = TextEditingController(
    text: _initial(widget.plan?.receivableAmount),
  );
  late final _coinsController = TextEditingController(
    text: _initial(widget.plan?.coins),
  );
  late final _offerController = TextEditingController(
    text: widget.plan?.offer ?? '',
  );
  late final _taglineController = TextEditingController(
    text: widget.plan?.tagline ?? '',
  );
  late PackagePreview? _preview = switch (widget.plan) {
    final plan? => (
      price: plan.payableAmount,
      coins: plan.coins,
      offer: plan.offer,
    ),
    null => null,
  };
  bool _submitted = false;

  static String _initial(int? value) => value == null ? '' : '$value';

  static int _parse(TextEditingController controller) =>
      int.tryParse(controller.text) ?? 0;

  List<TextEditingController> get _controllers => [
    _payableController,
    _receivableController,
    _coinsController,
    _offerController,
    _taglineController,
  ];

  String? _error(TextEditingController controller) =>
      _submitted && _parse(controller) <= 0 ? AppStrings.enterValue : null;

  void _onPayableChanged(String value) {
    final payable = int.tryParse(value);
    setState(() {
      _receivableController.text = payable == null
          ? ''
          : '${PackagePlan.receivableFor(payable, gst: _gst)}';
    });
  }

  void _onReceivableChanged(String value) {
    final receivable = int.tryParse(value);
    setState(() {
      _payableController.text = receivable == null
          ? ''
          : '${PackagePlan.payableFor(receivable, gst: _gst)}';
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
        coins: _parse(_coinsController),
        offer: _offerController.text,
      ),
    );
  }

  void _save() {
    final required = [
      _payableController,
      _receivableController,
      _coinsController,
    ];
    if (required.any((controller) => _parse(controller) <= 0)) {
      setState(() => _submitted = true);
      return;
    }
    Navigator.of(context).pop(
      PackagePlan(
        id: widget.plan?.id ?? 0,
        payableAmount: _parse(_payableController),
        receivableAmount: _parse(_receivableController),
        coins: _parse(_coinsController),
        offer: _offerController.text.trim(),
        tagline: _taglineController.text.trim(),
        totalRecharges: widget.plan?.totalRecharges ?? 0,
        gstEnabled: _gst,
      ),
    );
  }

  Widget _numberField(
    String label,
    TextEditingController controller, {
    ValueChanged<String>? onChanged,
  }) {
    return AppLabeledTextField(
      label: label,
      hint: label,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              NumberFormatter.rupees(plan.payableAmount),
              NumberFormatter.grouped(plan.coins),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (plan == null) ...[
            PackageGstToggle(value: _gst, onChanged: _onGstChanged),
            const SizedBox(height: _fieldGap),
          ],
          AppFieldRow(
            first: _numberField(
              AppStrings.payableAmountField,
              _payableController,
              onChanged: _onPayableChanged,
            ),
            second: _numberField(
              AppStrings.receivableAmountField,
              _receivableController,
              onChanged: _onReceivableChanged,
            ),
          ),
          const SizedBox(height: _fieldGap),
          _numberField(
            AppStrings.receivableCoin,
            _coinsController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: _fieldGap),
          AppFieldRow(
            first: _textField(AppStrings.offer, _offerController),
            second: _textField(AppStrings.tagline, _taglineController),
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
            label: AppStrings.savePackage,
            compact: true,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
