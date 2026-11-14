import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/app_theme.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';

class AllowedVersionsCard extends StatefulWidget {
  const AllowedVersionsCard({
    super.key,
    required this.versions,
    required this.enabled,
    required this.saving,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> versions;
  final bool enabled;
  final bool saving;
  final Future<bool> Function(String version) onAdd;
  final Future<bool> Function(String version) onRemove;

  @override
  State<AllowedVersionsCard> createState() => _AllowedVersionsCardState();
}

class _AllowedVersionsCardState extends State<AllowedVersionsCard> {
  static const double _subtitleGap = 2;
  static const double _sectionGap = 14;
  static const double _fieldWidth = 240;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(18, 16, 18, 18);
  static final RegExp _versionPattern = RegExp(r'^\d+(\.\d+){0,3}$');

  final TextEditingController _controller = TextEditingController();
  bool _submitted = false;

  String get _text => _controller.text.trim();

  String? get _error {
    if (!_submitted) return null;
    if (!_versionPattern.hasMatch(_text)) return AppStrings.enterAppVersion;
    if (widget.versions.contains(_text)) {
      return AppStrings.appVersionExists;
    }
    return null;
  }

  Future<void> _add() async {
    setState(() => _submitted = true);
    if (_error != null) return;
    final added = await widget.onAdd(_text);
    if (!mounted || !added) return;
    _controller.clear();
    setState(() => _submitted = false);
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
    final versions = widget.versions;
    final canEdit = widget.enabled && !widget.saving;

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
            AppStrings.allowedAppVersions,
            style: AppTextStyles.titleMedium.copyWith(color: textColor),
          ),
          const SizedBox(height: _subtitleGap),
          Text(
            AppStrings.allowedAppVersionsDescription,
            style: AppTextStyles.bodyMedium.copyWith(color: mutedColor),
          ),
          const SizedBox(height: _sectionGap),
          Wrap(
            spacing: AppUtils.spacingMd,
            runSpacing: AppUtils.spacingSm,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              SizedBox(
                width: _fieldWidth,
                child: AppLabeledTextField(
                  label: AppStrings.appVersion,
                  hint: AppStrings.appVersionHint,
                  controller: _controller,
                  readOnly: !widget.enabled,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => canEdit ? _add() : null,
                  errorText: _error,
                ),
              ),
              AppPrimaryButton(
                label: AppStrings.addVersion,
                compact: true,
                onPressed: canEdit ? _add : null,
              ),
            ],
          ),
          const SizedBox(height: _sectionGap),
          if (versions.isEmpty)
            Text(
              AppStrings.noAllowedVersions,
              style: AppTextStyles.bodyMedium.copyWith(color: mutedColor),
            )
          else
            Wrap(
              spacing: AppUtils.spacingSm,
              runSpacing: AppUtils.spacingSm,
              children: [
                for (final version in versions)
                  InputChip(
                    label: Text(version, style: AppTextStyles.bodyMedium),
                    deleteButtonTooltipMessage: AppStrings.removeVersion,
                    onDeleted: canEdit
                        ? () => widget.onRemove(version)
                        : null,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
