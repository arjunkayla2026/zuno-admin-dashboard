import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/core/widgets/documents/app_identity_documents.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/host_request.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/host_request_details_view.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/host_request_edit_form.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/host_request_header.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';

class HostRequestSheet extends StatefulWidget {
  const HostRequestSheet({
    super.key,
    required this.request,
    required this.onChanged,
  });

  final HostRequest request;
  final ValueChanged<HostRequest> onChanged;

  @override
  State<HostRequestSheet> createState() => _HostRequestSheetState();
}

class _HostRequestSheetState extends State<HostRequestSheet> {
  static const double _headerGap = 18;
  static const double _documentsGap = 18;
  static const double _footerGap = 10;
  static const double _editIconSize = 14;
  static final DateTime _firstBirthDate = DateTime(1940);

  late HostRequest _request = widget.request;
  bool _editing = false;

  late final _realNameController = TextEditingController();
  late final _nickNameController = TextEditingController();
  late final _phoneController = TextEditingController();
  late final _cityController = TextEditingController();
  late final _dateOfBirthController = TextEditingController();
  late DateTime _dateOfBirth;
  late HostGender _gender;
  late Set<HostLanguage> _languages;

  List<TextEditingController> get _controllers => [
    _realNameController,
    _nickNameController,
    _phoneController,
    _cityController,
    _dateOfBirthController,
  ];

  bool get _canSave => [
    _realNameController,
    _nickNameController,
    _phoneController,
  ].every((controller) => controller.text.trim().isNotEmpty);

  void _startEditing() {
    _realNameController.text = _request.realName;
    _nickNameController.text = _request.nickName;
    _phoneController.text = _request.phone;
    _cityController.text = _request.city;
    _dateOfBirth = _request.dateOfBirth;
    _dateOfBirthController.text = DateFormatter.short(_dateOfBirth);
    _gender = _request.gender;
    _languages = {..._request.languages};
    setState(() => _editing = true);
  }

  void _commit(HostRequest request) {
    widget.onChanged(request);
    setState(() => _request = request);
  }

  void _save() {
    _commit(
      _request.copyWith(
        realName: _realNameController.text.trim(),
        nickName: _nickNameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        languages: [
          for (final language in HostLanguage.values)
            if (_languages.contains(language)) language,
        ],
      ),
    );
    setState(() => _editing = false);
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: _firstBirthDate,
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _dateOfBirth = picked;
      _dateOfBirthController.text = DateFormatter.short(picked);
    });
  }

  void _decide(HostRequestStatus status) {
    widget.onChanged(_request.copyWith(status: status));
    Navigator.of(context).pop(status);
  }

  Future<void> _approve() async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      icon: Icons.check_circle_outline_rounded,
      title: AppStrings.approveRequestTitle,
      message: TextSpan(
        text: AppStrings.approveRequestMessage(_request.realName),
      ),
      confirmLabel: AppStrings.approve,
      positive: true,
    );
    if (confirmed && mounted) _decide(HostRequestStatus.approved);
  }

  Future<void> _reject() async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      icon: Icons.close_rounded,
      title: AppStrings.rejectRequestTitle,
      message: TextSpan(
        text: AppStrings.rejectRequestMessage(_request.realName),
      ),
      confirmLabel: AppStrings.reject,
    );
    if (confirmed && mounted) _decide(HostRequestStatus.rejected);
  }

  Widget _viewFooter() {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: AppUtils.spacingSm,
        children: [
          AppSecondaryButton(
            label: AppStrings.edit,
            onPressed: _startEditing,
            leading: SvgPicture.asset(
              AppImages.editIcon,
              width: _editIconSize,
              height: _editIconSize,
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
          ),
          if (_request.isPending)
            Wrap(
              spacing: _footerGap,
              runSpacing: AppUtils.spacingSm,
              children: [
                AppSecondaryButton(
                  label: AppStrings.reject,
                  destructive: true,
                  onPressed: _reject,
                ),
                AppPrimaryButton(
                  label: AppStrings.approve,
                  icon: Icons.check_rounded,
                  compact: true,
                  positive: true,
                  onPressed: _approve,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _editFooter() {
    return Wrap(
      spacing: _footerGap,
      runSpacing: AppUtils.spacingSm,
      children: [
        AppSecondaryButton(
          label: AppStrings.cancel,
          onPressed: () => setState(() => _editing = false),
        ),
        AppPrimaryButton(
          label: AppStrings.saveChanges,
          compact: true,
          onPressed: _canSave ? _save : null,
        ),
      ],
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
    final request = _request;

    return AppSideSheet(
      title: AppStrings.hostRequest,
      subtitle: AppStrings.hostRequestSubtitle(
        request.requestId,
        DateFormatter.short(request.submittedOn),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HostRequestHeader(request: request),
          const SizedBox(height: _headerGap),
          if (_editing)
            HostRequestEditForm(
              realNameController: _realNameController,
              nickNameController: _nickNameController,
              phoneController: _phoneController,
              dateOfBirthController: _dateOfBirthController,
              cityController: _cityController,
              gender: _gender,
              languages: _languages,
              onTextChanged: (_) => setState(() {}),
              onPickDateOfBirth: _pickDateOfBirth,
              onGenderChanged: (gender) => setState(() => _gender = gender),
              onLanguagesChanged: (languages) =>
                  setState(() => _languages = languages),
            )
          else
            HostRequestDetailsView(request: request),
          const SizedBox(height: _documentsGap),
          AppIdentityDocuments(
            name: request.realName,
            maskedAadhaar: request.maskedAadhaar,
            initials: request.initials,
            avatarIndex: request.avatarIndex,
            aadhaarImageUrl: request.aadhaarImageUrl,
            selfieImageUrl: request.selfieImageUrl,
            aadhaarLabel: AppStrings.aadhaarCardImage,
            selfieLabel: AppStrings.selfieUpload,
          ),
        ],
      ),
      footer: _editing ? _editFooter() : _viewFooter(),
    );
  }
}
