import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_error_banner.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_field_row.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_status_switch.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/data/models/surge_session.dart';
import 'package:zuno_admin_dashboard/features/surge_charge_sessions/presentation/widgets/surge_preview_note.dart';

class SurgeSessionSheet extends StatefulWidget {
  const SurgeSessionSheet({
    super.key,
    required this.takenNames,
    required this.onSave,
    this.session,
  });

  final SurgeSession? session;
  final Set<String> takenNames;
  final Future<String?> Function(SurgeSession session) onSave;

  static String nameKey(String name) => name.trim().toLowerCase();

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

  static const int _defaultStartMinutes = 20 * Duration.minutesPerHour;
  static const int _defaultEndMinutes = 23 * Duration.minutesPerHour;

  late int? _startMinutes = widget.session == null
      ? _defaultStartMinutes
      : widget.session!.startMinutes;
  late int? _endMinutes = widget.session == null
      ? _defaultEndMinutes
      : widget.session!.endMinutes;
  late bool _enabled = widget.session?.enabled ?? true;
  late final _nameController = TextEditingController(
    text: widget.session?.name ?? '',
  );
  late final _percentController = TextEditingController(
    text: widget.session == null ? '' : '${widget.session!.percent}',
  );
  late final _startController = TextEditingController(
    text: _timeText(_startMinutes),
  );
  late final _endController = TextEditingController(
    text: _timeText(_endMinutes),
  );
  bool _submitted = false;
  bool _saving = false;
  String? _errorMessage;

  static String _timeText(int? minutes) =>
      minutes == null ? '' : DateFormatter.minutesOfDay(minutes);

  int get _percent => int.tryParse(_percentController.text) ?? 0;

  String get _name => _nameController.text.trim();

  String? get _nameError {
    if (_name.isEmpty) return AppStrings.enterSessionName;
    if (widget.takenNames.contains(SurgeSessionSheet.nameKey(_name))) {
      return AppStrings.sessionNameTaken;
    }
    return null;
  }

  String? _missingTime(int? minutes) =>
      minutes == null ? AppStrings.selectTime : null;

  String? get _endError =>
      _missingTime(_endMinutes) ??
      (_startMinutes == _endMinutes ? AppStrings.endTimeMustDiffer : null);

  bool get _isValid =>
      _nameError == null &&
      _missingTime(_startMinutes) == null &&
      _endError == null &&
      _percent > 0;

  Future<void> _pickTime({required bool isStart}) async {
    final current =
        (isStart ? _startMinutes : _endMinutes) ??
        (isStart ? _defaultStartMinutes : _defaultEndMinutes);
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

  Future<void> _save() async {
    if (!_isValid) {
      setState(() => _submitted = true);
      return;
    }
    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    final original = widget.session;
    final keepTimes =
        original != null &&
        original.startTime != null &&
        original.endTime != null &&
        original.startMinutes == _startMinutes &&
        original.endMinutes == _endMinutes;
    final (startTime, endTime) = keepTimes
        ? (original.startTime!, original.endTime!)
        : SurgeSession.timesOn(DateTime.now(), _startMinutes!, _endMinutes!);
    final error = await widget.onSave(
      SurgeSession(
        id: original?.id ?? 0,
        name: _name,
        startTime: startTime,
        endTime: endTime,
        percent: _percent,
        enabled: _enabled,
      ),
    );
    if (!mounted) return;
    if (error == null) return Navigator.of(context).pop();
    setState(() {
      _saving = false;
      _errorMessage = error;
    });
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
      onTap: _saving ? null : () => _pickTime(isStart: isStart),
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
    _nameController.dispose();
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
          AppLabeledTextField(
            label: AppStrings.sessionNameField,
            hint: AppStrings.sessionNameHint,
            controller: _nameController,
            readOnly: _saving,
            inputFormatters: [
              LengthLimitingTextInputFormatter(SurgeSession.maxNameLength),
            ],
            onChanged: (_) => setState(() {}),
            errorText: _submitted ? _nameError : null,
            dense: true,
          ),
          const SizedBox(height: _rowGap),
          AppFieldRow(
            first: _timeField(
              label: AppStrings.startTimeField,
              controller: _startController,
              isStart: true,
              errorText: _submitted ? _missingTime(_startMinutes) : null,
            ),
            second: _timeField(
              label: AppStrings.endTimeField,
              controller: _endController,
              isStart: false,
              errorText: _submitted ? _endError : null,
            ),
          ),
          const SizedBox(height: _rowGap),
          AppLabeledTextField(
            label: AppStrings.surgeChargeField,
            hint: AppStrings.surgeChargeHint,
            controller: _percentController,
            readOnly: _saving,
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
                onChanged: (enabled) {
                  if (!_saving) setState(() => _enabled = enabled);
                },
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
          if (_errorMessage case final error?) ...[
            const SizedBox(height: _sectionGap),
            AppErrorBanner(message: error),
          ],
        ],
      ),
      footer: Wrap(
        spacing: _footerGap,
        runSpacing: AppUtils.spacingSm,
        children: [
          AppSecondaryButton(
            label: AppStrings.cancel,
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
          ),
          AppPrimaryButton(
            label: _saving ? AppStrings.saving : AppStrings.saveSession,
            compact: true,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
