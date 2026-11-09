import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_field_row.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_switch.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/data/mock/surge_session_mock_data.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/data/models/surge_session.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/widgets/surge_preview_note.dart';

class SurgeSessionSheet extends StatefulWidget {
  const SurgeSessionSheet({super.key, this.session});

  final SurgeSession? session;

  @override
  State<SurgeSessionSheet> createState() => _SurgeSessionSheetState();
}

class _SurgeSessionSheetState extends State<SurgeSessionSheet> {
  static const double _rowGap = 14;
  static const double _helperGap = 6;
  static const double _sectionGap = 18;
  static const double _statusGap = 6;
  static const double _switchGap = 10;
  static const double _footerGap = 10;
  static const double _clockIconSize = 16;
  static const EdgeInsets _clockPadding = EdgeInsets.only(
    right: AppUtils.spacingMd,
  );

  late int _startMinutes =
      widget.session?.startMinutes ?? SurgeSessionMockData.defaultStartMinutes;
  late int _endMinutes =
      widget.session?.endMinutes ?? SurgeSessionMockData.defaultEndMinutes;
  late bool _enabled = widget.session?.enabled ?? true;
  late final _percentController = TextEditingController(
    text: widget.session == null ? '' : '${widget.session!.percent}',
  );
  late final _startController = TextEditingController(
    text: DateFormatter.minutesOfDay(_startMinutes),
  );
  late final _endController = TextEditingController(
    text: DateFormatter.minutesOfDay(_endMinutes),
  );
  bool _submitted = false;

  int get _percent => int.tryParse(_percentController.text) ?? 0;

  bool get _sameTimes => _startMinutes == _endMinutes;

  Future<void> _pickTime({required bool isStart}) async {
    final current = isStart ? _startMinutes : _endMinutes;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: current ~/ Duration.minutesPerHour,
        minute: current % Duration.minutesPerHour,
      ),
    );
    if (picked == null) return;
    final minutes = picked.hour * Duration.minutesPerHour + picked.minute;
    setState(() {
      if (isStart) {
        _startMinutes = minutes;
        _startController.text = DateFormatter.minutesOfDay(minutes);
      } else {
        _endMinutes = minutes;
        _endController.text = DateFormatter.minutesOfDay(minutes);
      }
    });
  }

  void _save() {
    if (_percent <= 0 || _sameTimes) {
      setState(() => _submitted = true);
      return;
    }
    Navigator.of(context).pop(
      SurgeSession(
        id: widget.session?.id ?? 0,
        startMinutes: _startMinutes,
        endMinutes: _endMinutes,
        percent: _percent,
        enabled: _enabled,
      ),
    );
  }

  Widget _timeField({
    required String label,
    required TextEditingController controller,
    required bool isStart,
    String? errorText,
  }) {
    return AppLabeledTextField(
      label: label,
      hint: label,
      controller: controller,
      readOnly: true,
      dense: true,
      errorText: errorText,
      onTap: () => _pickTime(isStart: isStart),
      suffix: Padding(
        padding: _clockPadding,
        child: Icon(
          Icons.schedule_rounded,
          size: _clockIconSize,
          color: context.colorScheme.onSurface,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _percentController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.colorScheme.onSurface;

    return AppSideSheet(
      title: widget.session == null
          ? AppStrings.createSurgeSession
          : AppStrings.editSurgeSession,
      subtitle: AppStrings.surgeSheetSubtitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFieldRow(
            first: _timeField(
              label: AppStrings.startTimeField,
              controller: _startController,
              isStart: true,
            ),
            second: _timeField(
              label: AppStrings.endTimeField,
              controller: _endController,
              isStart: false,
              errorText: _submitted && _sameTimes
                  ? AppStrings.endTimeMustDiffer
                  : null,
            ),
          ),
          const SizedBox(height: _rowGap),
          AppLabeledTextField(
            label: AppStrings.surgeChargeField,
            hint: AppStrings.surgeChargeHint,
            controller: _percentController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            errorText: _submitted && _percent <= 0
                ? AppStrings.enterSurgeCharge
                : null,
            dense: true,
          ),
          const SizedBox(height: _helperGap),
          Text(
            AppStrings.surgeChargeHelper,
            style: AppTextStyles.captionSmall.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: _sectionGap),
          Text(
            AppStrings.status,
            style: AppTextStyles.labelSmall.copyWith(color: textColor),
          ),
          const SizedBox(height: _statusGap),
          Row(
            children: [
              AppStatusSwitch(
                value: _enabled,
                onChanged: (enabled) => setState(() => _enabled = enabled),
              ),
              const SizedBox(width: _switchGap),
              Text(
                _enabled ? AppStrings.enabled : AppStrings.disabled,
                style: AppTextStyles.labelMedium.copyWith(color: textColor),
              ),
            ],
          ),
          const SizedBox(height: _sectionGap),
          SurgePreviewNote(
            percent: _percent,
            start: _startController.text,
            end: _endController.text,
          ),
        ],
      ),
      footer: Wrap(
        spacing: _footerGap,
        runSpacing: AppUtils.spacingSm,
        children: [
          AppSecondaryButton(
            label: AppStrings.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppPrimaryButton(
            label: AppStrings.saveSession,
            compact: true,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
