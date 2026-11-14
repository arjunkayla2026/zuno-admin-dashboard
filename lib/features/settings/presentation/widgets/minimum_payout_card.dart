import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/decimal_input_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';

class MinimumPayoutCard extends StatefulWidget {
  const MinimumPayoutCard({
    super.key,
    required this.amount,
    required this.enabled,
    required this.saving,
    required this.onSave,
  });

  final double? amount;
  final bool enabled;
  final bool saving;
  final ValueChanged<double> onSave;

  @override
  State<MinimumPayoutCard> createState() => _MinimumPayoutCardState();
}

class _MinimumPayoutCardState extends State<MinimumPayoutCard> {
  static const double _subtitleGap = 2;
  static const double _fieldGap = 14;
  static const double _fieldWidth = 240;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(18, 16, 18, 18);

  late final TextEditingController _controller = TextEditingController(
    text: _textOf(widget.amount),
  );
  bool _submitted = false;

  static String _textOf(double? amount) =>
      amount == null ? '' : NumberFormatter.trimmedAmount(amount);

  double? get _amount => NumberFormatter.tryParseAmount(_controller.text);

  @override
  void didUpdateWidget(MinimumPayoutCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _controller.text = _textOf(widget.amount);
    }
  }

  void _save() {
    final amount = _amount;
    if (amount == null) {
      setState(() => _submitted = true);
      return;
    }
    widget.onSave(amount);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final mutedColor = context.appColors.textSecondary;

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.minimumPayoutAmount,
            style: AppTextStyles.titleMedium.copyWith(color: textColor),
          ),
          const SizedBox(height: _subtitleGap),
          Text(
            widget.amount == null
                ? '${AppStrings.minimumPayoutDescription} '
                      '${AppStrings.minimumPayoutNotSet}'
                : AppStrings.minimumPayoutDescription,
            style: AppTextStyles.bodyMedium.copyWith(color: mutedColor),
          ),
          const SizedBox(height: _fieldGap),
          Wrap(
            spacing: AppUtils.spacingMd,
            runSpacing: AppUtils.spacingSm,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: _fieldWidth,
                child: AppLabeledTextField(
                  label: AppStrings.amount,
                  hint: AppStrings.typeHint,
                  controller: _controller,
                  readOnly: !widget.enabled,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [DecimalInputFormatter()],
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _save(),
                  errorText: _submitted && _amount == null
                      ? AppStrings.enterAmount
                      : null,
                ),
              ),
              AppPrimaryButton(
                label: AppStrings.save,
                compact: true,
                onPressed: widget.enabled && !widget.saving ? _save : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
