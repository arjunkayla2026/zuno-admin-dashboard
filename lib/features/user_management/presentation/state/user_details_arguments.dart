import 'package:flutter/foundation.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/models/admin_user.dart';

class UserDetailsArguments {
  const UserDetailsArguments({required this.user, this.onUserChanged});

  final AdminUser user;
  final ValueChanged<AdminUser>? onUserChanged;
}
