import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zuno_admin_dashboard/core/navigation/app_routes.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/theme/theme_utils.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_details_route_loader.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_details_shell.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_details_view.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_details_arguments.dart';

class HostDetailsPage extends StatelessWidget {
  const HostDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = ModalRoute.of(context)?.settings;
    final arguments = settings?.arguments;
    final hostId = AppRoutes.recordIdOf(settings);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.pageOverlayStyle,
      child: switch ((arguments, hostId)) {
        (final HostDetailsArguments arguments, _) => HostDetailsView(
          arguments: arguments,
        ),
        (_, final String hostId) => HostDetailsRouteLoader(hostId: hostId),
        _ => HostDetailsShell.message(message: AppStrings.hostNotFound),
      },
    );
  }
}
