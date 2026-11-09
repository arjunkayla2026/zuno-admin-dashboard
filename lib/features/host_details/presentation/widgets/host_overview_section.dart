import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/state/host_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_documents_card.dart';
import 'package:zuno_admin_dashboard/features/host_details/presentation/widgets/host_profile_card.dart';

class HostOverviewSection extends StatelessWidget {
  const HostOverviewSection({super.key});

  static const double _sideBySideWidth = 900;
  static const double _gap = 18;
  static const int _profileFlex = 442;
  static const int _documentsFlex = 200;

  @override
  Widget build(BuildContext context) {
    final host = context.select((HostDetailsCubit cubit) => cubit.state.host);
    final profile = HostProfileCard(host: host);
    final documents = HostDocumentsCard(host: host);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _sideBySideWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              profile,
              const SizedBox(height: _gap),
              documents,
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: _profileFlex, child: profile),
              const SizedBox(width: _gap),
              Expanded(flex: _documentsFlex, child: documents),
            ],
          ),
        );
      },
    );
  }
}
