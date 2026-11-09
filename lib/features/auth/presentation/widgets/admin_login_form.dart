import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/app_text_styles.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_error_banner.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_labeled_text_field.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_primary_button.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/widgets/password_visibility_toggle.dart';

class AdminLoginForm extends StatefulWidget {
  const AdminLoginForm({
    super.key,
    required this.onSignIn,
    this.isLoading = false,
    this.errorMessage,
  });

  final void Function(String email, String password) onSignIn;
  final bool isLoading;
  final String? errorMessage;

  @override
  State<AdminLoginForm> createState() => _AdminLoginFormState();
}

class _AdminLoginFormState extends State<AdminLoginForm> {
  static const double _formWidth = 440;
  static const double _labelToHeadingGap = 4;
  static const double _headingToFieldsGap = 18;
  static const double _headingToBannerGap = 20;
  static const double _bannerToFieldsGap = 15;
  static const double _fieldGap = 18;
  static const double _fieldsToButtonGap = 20;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _submit() =>
      widget.onSignIn(_emailController.text, _passwordController.text);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppUtils.spacingXl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _formWidth),
            child: AutofillGroup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.adminSignIn.toUpperCase(),
                    style: AppTextStyles.sectionLabel.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: _labelToHeadingGap),
                  Text(
                    AppStrings.welcomeBack,
                    style: AppTextStyles.sectionHeading.copyWith(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  if (widget.errorMessage case final message?) ...[
                    const SizedBox(height: _headingToBannerGap),
                    AppErrorBanner(message: message),
                    const SizedBox(height: _bannerToFieldsGap),
                  ] else
                    const SizedBox(height: _headingToFieldsGap),
                  AppLabeledTextField(
                    label: AppStrings.email,
                    hint: AppStrings.emailHint,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: _fieldGap),
                  AppLabeledTextField(
                    label: AppStrings.password,
                    hint: AppStrings.passwordHint,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _submit(),
                    suffix: PasswordVisibilityToggle(
                      obscured: _obscurePassword,
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: _fieldsToButtonGap),
                  AppPrimaryButton(
                    label: widget.isLoading
                        ? AppStrings.signingIn
                        : AppStrings.signInSecurely,
                    icon: Icons.lock_outline_rounded,
                    onPressed: widget.isLoading ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
