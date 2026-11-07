import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_choice_chips.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_segmented_control.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/widgets/host_profile_labels.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_state.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/widgets/notification_audience_card.dart';

enum NotificationAudience { users, hosts, both }

class NotificationComposerSection extends StatefulWidget {
  const NotificationComposerSection({super.key});

  @override
  State<NotificationComposerSection> createState() =>
      _NotificationComposerSectionState();
}

class _NotificationComposerSectionState
    extends State<NotificationComposerSection> {
  static const double _audienceWidth = 298;
  static const double _columnGap = 26;
  static const double _stackBreakpoint = 760;
  static const double _labelGap = 8;
  static const double _helperGap = 4;
  static const double _fieldGap = 18;
  static const double _actionsGap = 22;
  static const int _messageLines = 4;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(22, 22, 22, 22);

  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  NotificationAudience _audience = NotificationAudience.both;
  Set<HostLanguage> _languages = {};
  bool _submitted = false;

  bool get _includesUsers => _audience != NotificationAudience.hosts;

  bool get _includesHosts => _audience != NotificationAudience.users;

  bool get _titleValid => _titleController.text.trim().isNotEmpty;

  bool get _messageValid => _messageController.text.trim().isNotEmpty;

  String? _error(bool valid, String message) =>
      _submitted && !valid ? message : null;

  void _send() {
    setState(() => _submitted = true);
  }

  void _clear() {
    _titleController.clear();
    _messageController.clear();
    setState(() {
      _audience = NotificationAudience.both;
      _languages = {};
      _submitted = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Widget _form(BuildContext context) {
    final textColor = context.colorScheme.onSurface;
    final label = AppTextStyles.labelSmall.copyWith(color: textColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.sendTo, style: label),
        const SizedBox(height: _labelGap),
        AppSegmentedControl<NotificationAudience>(
          options: const {
            NotificationAudience.users: AppStrings.userAudience,
            NotificationAudience.hosts: AppStrings.hostAudience,
            NotificationAudience.both: AppStrings.bothAudience,
          },
          value: _audience,
          onChanged: (audience) => setState(() => _audience = audience),
        ),
        if (_includesHosts) ...[
          const SizedBox(height: _fieldGap),
          Text(AppStrings.hostMotherTongue, style: label),
          const SizedBox(height: _helperGap),
          Text(
            AppStrings.hostMotherTongueHelper,
            style: AppTextStyles.captionSmall.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: _labelGap),
          AppChoiceChips<HostLanguage>(
            options: HostLanguage.values,
            selected: _languages,
            labelOf: HostProfileLabels.language,
            onChanged: (languages) => setState(() => _languages = languages),
          ),
        ],
        const SizedBox(height: _fieldGap),
        AppLabeledTextField(
          label: AppStrings.notificationTitle,
          hint: AppStrings.notificationTitleHint,
          controller: _titleController,
          textInputAction: TextInputAction.next,
          errorText: _error(_titleValid, AppStrings.enterTitle),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: _fieldGap),
        AppLabeledTextField(
          label: AppStrings.notificationMessage,
          hint: AppStrings.notificationMessageHint,
          controller: _messageController,
          keyboardType: TextInputType.multiline,
          minLines: _messageLines,
          maxLines: null,
          errorText: _error(_messageValid, AppStrings.enterMessage),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: _actionsGap),
        Wrap(
          spacing: AppUtils.spacingSm,
          runSpacing: AppUtils.spacingSm,
          children: [
            AppPrimaryButton(
              label: AppStrings.sendNotification,
              icon: Icons.send_outlined,
              compact: true,
              onPressed: _send,
            ),
            AppSecondaryButton(label: AppStrings.clear, onPressed: _clear),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding,
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) =>
            previous.activeUsers != current.activeUsers ||
            previous.activeHostsByLanguage != current.activeHostsByLanguage,
        builder: (context, state) {
          final audience = NotificationAudienceCard(
            users: _includesUsers ? state.activeUsers : 0,
            hosts: _includesHosts ? state.activeHostsFor(_languages) : 0,
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < _stackBreakpoint) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _form(context),
                    const SizedBox(height: _columnGap),
                    audience,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _form(context)),
                  const SizedBox(width: _columnGap),
                  SizedBox(width: _audienceWidth, child: audience),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
