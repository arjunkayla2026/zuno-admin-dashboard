import 'dart:typed_data';

import 'package:zuno_admin_dashboard/features/settings/data/models/banner_image.dart';

class BannerUpload {
  const BannerUpload({
    required this.bytes,
    required this.fileName,
    required this.contentType,
    required this.role,
    required this.screen,
  });

  final Uint8List bytes;
  final String fileName;
  final String contentType;
  final BannerAudience role;
  final BannerScreen screen;
}
