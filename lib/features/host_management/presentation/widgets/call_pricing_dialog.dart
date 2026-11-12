import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/data/host_pricing.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/decimal_input_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_header.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_error_banner.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_segmented_control.dart';

class CallPricingDialog extends StatefulWidget {
  const CallPricingDialog({
    super.key,
    required this.pricing,
    required this.onSave,
  });

  final HostPricing pricing;
  final Future<String?> Function(HostPricing pricing) onSave;

  @override
  State<CallPricingDialog> createState() => _CallPricingDialogState();
}

class _CallPricingDialogState extends State<CallPricingDialog> {
  static const double _headerGap = 18;
  static const double _segmentGap = 18;
  static const double _segmentWidth = 124;
  static const double _fieldGap = 12;
  static const double _rowGap = 14;
  static const double _actionsGap = 24;
  static const double _actionSpacing = 10;
  static const EdgeInsets _padding = EdgeInsets.all(AppUtils.spacingXl);
  static const Map<PricingSide, String> _sides = {
    PricingSide.admin: AppStrings.admin,
    PricingSide.host: AppStrings.hostRole,
  };

  final _amountFormatter = DecimalInputFormatter();

  PricingSide _side = PricingSide.admin;
  bool _submitted = false;
  bool _saving = false;
  String? _errorMessage;

  late final Map<(PricingChannel, PricingSide), TextEditingController>
  _amounts = {
    for (final channel in PricingChannel.values)
      for (final side in PricingSide.values.where(channel.supports))
        (channel, side): TextEditingController(
          text: NumberFormatter.amountInput(
            widget.pricing.of(channel).amountFor(side),
          ),
        ),
  };

  double? _amount(PricingChannel channel, PricingSide side) =>
      NumberFormatter.tryParseAmount(_amounts[(channel, side)]!.text);

  bool _sideIsValid(PricingSide side) => PricingChannel.values.every(
    (channel) => !channel.supports(side) || _amount(channel, side) != null,
  );

  HostPricing _pricing() => HostPricing(
    audio: _channel(PricingChannel.audio),
    video: _channel(PricingChannel.video),
    message: _channel(PricingChannel.message),
  );

  ChannelPricing _channel(PricingChannel channel) => ChannelPricing(
    adminAmount: _amount(channel, PricingSide.admin)!,
    hostAmount: channel.hasHostAmount ? _amount(channel, PricingSide.host)! : 0,
  );

  Future<void> _save() async {
    final invalidSides = PricingSide.values.where(
      (side) => !_sideIsValid(side),
    );
    if (invalidSides.isNotEmpty) {
      setState(() {
        _submitted = true;
        if (!invalidSides.contains(_side)) _side = invalidSides.first;
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    final error = await widget.onSave(_pricing());
    if (!mounted) return;
    if (error == null) return Navigator.of(context).pop();
    setState(() {
      _saving = false;
      _errorMessage = error;
    });
  }

  Widget _amountField(String label, PricingChannel channel) {
    return AppLabeledTextField(
      label: label,
      hint: label,
      controller: _amounts[(channel, _side)]!,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [_amountFormatter],
      onChanged: (_) => setState(() {}),
      readOnly: _saving,
      errorText: _submitted && _amount(channel, _side) == null
          ? AppStrings.enterAmount
          : null,
      dense: true,
    );
  }

  @override
  void dispose() {
    for (final controller in _amounts.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = _errorMessage;

    return AppDialogSurface(
      padding: _padding,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDialogHeader(
              icon: SvgPicture.asset(
                AppImages.dbIcon,
                width: AppDialogHeader.iconSize,
                height: AppDialogHeader.iconSize,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryDark,
                  BlendMode.srcIn,
                ),
              ),
              title: AppStrings.setCallMessagePrice,
              subtitle: AppStrings.pricingSubtitle,
            ),
            const SizedBox(height: _headerGap),
            Center(
              child: AppSegmentedControl<PricingSide>(
                options: _sides,
                value: _side,
                segmentWidth: _segmentWidth,
                onChanged: (side) {
                  if (!_saving) setState(() => _side = side);
                },
              ),
            ),
            const SizedBox(height: _segmentGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _amountField(
                    AppStrings.audioCallRateField,
                    PricingChannel.audio,
                  ),
                ),
                const SizedBox(width: _fieldGap),
                Expanded(
                  child: _amountField(
                    AppStrings.videoCallRateField,
                    PricingChannel.video,
                  ),
                ),
              ],
            ),
            if (PricingChannel.message.supports(_side)) ...[
              const SizedBox(height: _rowGap),
              _amountField(AppStrings.messageRateField, PricingChannel.message),
            ],
            if (error != null) ...[
              const SizedBox(height: _rowGap),
              AppErrorBanner(message: error),
            ],
            const SizedBox(height: _actionsGap),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: _actionSpacing,
              runSpacing: AppUtils.spacingSm,
              children: [
                AppSecondaryButton(
                  label: AppStrings.cancel,
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                ),
                AppPrimaryButton(
                  label: _saving ? AppStrings.saving : AppStrings.savePrices,
                  compact: true,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
