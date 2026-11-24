import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/user_details_route_loader.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/user_details_shell.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/widgets/user_details_view.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_details_arguments.dart';

class UserDetailsPage extends StatelessWidget {
  const UserDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = ModalRoute.of(context)?.settings;
    final arguments = settings?.arguments;
    final userId = AppRoutes.recordIdOf(settings);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: switch ((arguments, userId)) {
        (final UserDetailsArguments arguments, _) => UserDetailsView(
          arguments: arguments,
        ),
        (_, final String userId) => UserDetailsRouteLoader(userId: userId),
        _ => UserDetailsShell.message(message: AppStrings.userNotFound),
      },
    );
  }
}
