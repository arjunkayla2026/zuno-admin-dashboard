import 'package:flutter/material.dart';
import 'package:zuno_admin_dashboard/core/data/profile_photo_lookup.dart';
import 'package:zuno_admin_dashboard/core/di/injection_container.dart';
import 'package:zuno_admin_dashboard/core/widgets/app_initials_avatar.dart';

/// An [AppInitialsAvatar] that finds the person's profile picture by
/// [userId] through [ProfilePhotoLookup]. Use it where only the ID is known;
/// where the user record is already loaded, pass its image to
/// [AppInitialsAvatar.imageUrl] instead.
class AppUserPhotoAvatar extends StatelessWidget {
  const AppUserPhotoAvatar({
    super.key,
    required this.userId,
    required this.initials,
    required this.color,
    this.size = 34,
    this.borderRadius,
    this.textStyle,
  });

  final String userId;
  final String initials;
  final Color color;
  final double size;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;

  Widget _avatar(String? imageUrl) => AppInitialsAvatar(
    initials: initials,
    color: color,
    size: size,
    borderRadius: borderRadius,
    textStyle: textStyle,
    imageUrl: imageUrl,
  );

  @override
  Widget build(BuildContext context) {
    // Screens built without the app's services (such as in tests) keep the
    // initials.
    if (userId.isEmpty || !getIt.isRegistered<ProfilePhotoLookup>()) {
      return _avatar(null);
    }
    return ValueListenableBuilder<String?>(
      valueListenable: getIt<ProfilePhotoLookup>().photoOf(userId),
      builder: (context, imageUrl, _) => _avatar(imageUrl),
    );
  }
}
