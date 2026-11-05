import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/theme/app_colors.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/widgets/login_brand_footer.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/widgets/login_brand_header.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/widgets/login_brand_message.dart';

class LoginBrandPanel extends StatelessWidget {
  const LoginBrandPanel({super.key});

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 72,
    vertical: 64,
  );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.sidebarBackground,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: _padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - _padding.vertical,
              ),
              child: const IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LoginBrandHeader(),
                    LoginBrandMessage(),
                    LoginBrandFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
