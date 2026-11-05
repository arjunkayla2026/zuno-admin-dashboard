import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/widgets/admin_login_form.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/widgets/login_brand_panel.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/pages/dashboard_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  String? _errorMessage;

  void _onSignIn() => setState(
    () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DashboardPage()),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (AppUtils.isDesktop(context))
              const Expanded(child: LoginBrandPanel()),
            Expanded(
              child: AdminLoginForm(
                onSignIn: _onSignIn,
                errorMessage: _errorMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
