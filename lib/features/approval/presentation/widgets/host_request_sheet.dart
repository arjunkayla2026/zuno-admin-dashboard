import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zuno_admin_dashboard/core/resources/images/app_images.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_confirm_dialog.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_error_banner.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_secondary_button.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_side_sheet.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/host_request.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/host_request_details_view.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/host_request_edit_form.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/host_request_header.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/host_request_labels.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/widgets/host_verification_documents.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/host_profile_options.dart';

class HostRequestSheet extends StatefulWidget {
  const HostRequestSheet({
    super.key,
    required this.request,
    required this.onChanged,
    required this.onReview,
    required this.onDecide,
  });

  final HostRequest request;
  final ValueChanged<HostRequest> onChanged;
  final Future<String?> Function(
    HostRequest request,
    HostDocumentType type,
    HostRequestStatus decision,
  )
  onReview;
  final Future<String?> Function(
    HostRequest request,
    HostRequestStatus decision,
  )
  onDecide;

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
  bool _reviewing = false;
  String? _errorMessage;

  late final _realNameController = TextEditingController();
  late final _nickNameController = TextEditingController();
  late final _phoneController = TextEditingController();
  late final _cityController = TextEditingController();
  late final _dateOfBirthController = TextEditingController();
  DateTime? _dateOfBirth;
  HostGender? _gender;
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
    _dateOfBirthController.text = HostRequestLabels.dateOfBirth(_request);
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
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20),
      firstDate: _firstBirthDate,
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _dateOfBirth = picked;
      _dateOfBirthController.text = DateFormatter.short(picked);
    });
  }

  Future<void> _review(
    HostDocument document,
    HostRequestStatus decision,
  ) async {
    final approving = decision == HostRequestStatus.approved;
    final label = HostRequestLabels.document(document.type);
    final confirmed = await showAppConfirmDialog(
      context: context,
      icon: approving
          ? Icons.check_circle_outline_rounded
          : Icons.close_rounded,
      title: approving
          ? AppStrings.approveDocumentTitle(label)
          : AppStrings.rejectDocumentTitle(label),
      message: TextSpan(
        text: approving
            ? AppStrings.approveDocumentMessage(label, _request.realName)
            : AppStrings.rejectDocumentMessage(label, _request.realName),
      ),
      confirmLabel: approving ? AppStrings.approve : AppStrings.reject,
      positive: approving,
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _reviewing = true;
      _errorMessage = null;
    });
    final error = await widget.onReview(_request, document.type, decision);
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _reviewing = false;
        _errorMessage = error;
      });
      return;
    }

    setState(() {
      _reviewing = false;
      _request = _request.withDocumentStatus(document.type, decision);
    });
  }

  Future<void> _decide(HostRequestStatus decision) async {
    setState(() {
      _reviewing = true;
      _errorMessage = null;
    });
    final error = await widget.onDecide(_request, decision);
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _reviewing = false;
        _errorMessage = error;
      });
      return;
    }
    Navigator.of(context).pop(decision);
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
    if (confirmed && mounted) await _decide(HostRequestStatus.approved);
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
    if (confirmed && mounted) await _decide(HostRequestStatus.rejected);
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
          if (_request.canDecide)
            Wrap(
              spacing: _footerGap,
              runSpacing: AppUtils.spacingSm,
              children: [
                AppSecondaryButton(
                  label: AppStrings.reject,
                  destructive: true,
                  onPressed: _reviewing ? null : _reject,
                ),
                AppPrimaryButton(
                  label: AppStrings.approve,
                  icon: Icons.check_rounded,
                  compact: true,
                  positive: true,
                  onPressed: _reviewing ? null : _approve,
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
          HostVerificationDocuments(
            request: request,
            isBusy: _reviewing,
            onReview: _review,
          ),
          if (_errorMessage case final message?) ...[
            const SizedBox(height: _documentsGap),
            AppErrorBanner(message: message),
          ],
        ],
      ),
      footer: _editing ? _editFooter() : _viewFooter(),
    );
  }
}
