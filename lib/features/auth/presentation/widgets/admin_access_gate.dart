import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_shell.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_empty_state.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_table_load_state.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/admin_session_cubit.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/admin_session_state.dart';

class AdminAccessGate extends StatelessWidget {
  const AdminAccessGate({super.key, required this.module, required this.child});

  final AdminNavItem module;
  final Widget child;

  bool _allowed(AdminSessionState state) =>
      state.account?.canAccess(module) ?? false;

  void _onBack(BuildContext context, bool didPop) {
    if (didPop) return;
    final route = ModalRoute.of(context);
    if (route == null || !route.isFirst) return;
    final home = context.read<AdminSessionCubit>().state.account?.homeRoute;
    if (home == null || home == route.settings.name) return;
    Navigator.of(context).pushReplacementNamed(home);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      onPopInvokedWithResult: (didPop, _) => _onBack(context, didPop),
      child: _buildGate(context),
    );
  }

  Widget _buildGate(BuildContext context) {
    return BlocBuilder<AdminSessionCubit, AdminSessionState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          _allowed(previous) != _allowed(current),
      builder: (context, state) => switch (state.status) {
        AdminSessionStatus.loading => const _GateScaffold(
          child: AppTableLoadingState(),
        ),
        AdminSessionStatus.failure => _GateScaffold(
          child: AppTableErrorState(
            message: state.errorMessage ?? AppStrings.recordsLoadFailed,
            onRetry: context.read<AdminSessionCubit>().restore,
          ),
        ),
        AdminSessionStatus.signedOut => const _LoginRedirect(),
        AdminSessionStatus.signedIn when _allowed(state) => child,
        AdminSessionStatus.signedIn => AdminShell(
          selectedItem: module,
          userName: state.account?.name ?? '',
          userRole: state.account?.role.label ?? '',
          userInitials: state.account?.initials ?? '',
          child: const SingleChildScrollView(
            child: AppEmptyState(
              icon: Icons.lock_outline_rounded,
              title: AppStrings.noModuleAccessTitle,
              message: AppStrings.noModuleAccessMessage,
            ),
          ),
        ),
      },
    );
  }
}

class _GateScaffold extends StatelessWidget {
  const _GateScaffold({required this.child});

  static const double _maxWidth = 480;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginRedirect extends StatefulWidget {
  const _LoginRedirect();

  @override
  State<_LoginRedirect> createState() => _LoginRedirectState();
}

class _LoginRedirectState extends State<_LoginRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold();
}
