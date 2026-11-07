import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_header.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_dialog_surface.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/call_pricing.dart';

class CallPricingDialog extends StatefulWidget {
  const CallPricingDialog({super.key, required this.pricing});

  final CallPricing pricing;

  @override
  State<CallPricingDialog> createState() => _CallPricingDialogState();
}

class _CallPricingDialogState extends State<CallPricingDialog> {
  static const double _headerGap = 18;
  static const double _fieldGap = 12;
  static const double _rowGap = 14;
  static const double _actionsGap = 24;
  static const double _actionSpacing = 10;
  static const EdgeInsets _padding = EdgeInsets.all(AppUtils.spacingXl);

  late final _audioController = TextEditingController(
    text: '${widget.pricing.audioPerSecond}',
  );
  late final _videoController = TextEditingController(
    text: '${widget.pricing.videoPerSecond}',
  );
  late final _messageController = TextEditingController(
    text: '${widget.pricing.perMessage}',
  );

  List<TextEditingController> get _controllers => [
    _audioController,
    _videoController,
    _messageController,
  ];

  bool get _canSave =>
      _controllers.every((controller) => int.tryParse(controller.text) != null);

  void _onChanged(String _) => setState(() {});

  void _save() {
    Navigator.of(context).pop(
      CallPricing(
        audioPerSecond: int.parse(_audioController.text),
        videoPerSecond: int.parse(_videoController.text),
        perMessage: int.parse(_messageController.text),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return AppLabeledTextField(
      label: label,
      hint: label,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: _onChanged,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _field(
                    AppStrings.audioCallRateField,
                    _audioController,
                  ),
                ),
                const SizedBox(width: _fieldGap),
                Expanded(
                  child: _field(
                    AppStrings.videoCallRateField,
                    _videoController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: _rowGap),
            _field(AppStrings.messageRateField, _messageController),
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
                  label: AppStrings.savePrices,
                  compact: true,
                  onPressed: _canSave ? _save : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
