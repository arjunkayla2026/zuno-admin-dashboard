import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/di/injection_container.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/core/utils/app_utils.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/admin_session_cubit.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/admin_session_state.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/auth_cubit.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/auth_state.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/widgets/admin_login_form.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/widgets/login_brand_panel.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  void _openHome(BuildContext context, AdminSessionState state) {
    final route = state.account?.homeRoute;
    if (route != null) Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: BlocProvider(
        create: (_) => getIt<AuthCubit>(),
        child: BlocListener<AdminSessionCubit, AdminSessionState>(
          listenWhen: (_, state) => state.status == AdminSessionStatus.signedIn,
          listener: _openHome,
          child: Scaffold(
            backgroundColor: context.colorScheme.surface,
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (AppUtils.isDesktop(context))
                  const Expanded(child: LoginBrandPanel()),
                Expanded(
                  child: BlocConsumer<AuthCubit, AuthState>(
                    listenWhen: (_, state) =>
                        state.status == AuthStatus.success,
                    listener: (context, state) {
                      if (state.account case final account?) {
                        context.read<AdminSessionCubit>().signedIn(account);
                      }
                    },
                    builder: (context, state) => AdminLoginForm(
                      onSignIn: (email, password) => context
                          .read<AuthCubit>()
                          .signIn(email: email, password: password),
                      isLoading: state.isLoading,
                      errorMessage: state.errorMessage,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
