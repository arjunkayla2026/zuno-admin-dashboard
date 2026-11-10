import 'package:cloud_firestore/cloud_firestore.dart';

enum BannerAudience { user, host }

enum BannerStatus { active, inactive }

class BannerImage {
  const BannerImage({
    required this.id,
    required this.imageName,
    required this.imageUrl,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  factory BannerImage.fromFirestore(String id, Map<String, dynamic> data) {
    final createdAt = data[createdAtField];
    return BannerImage(
      id: id,
      imageName: data[imageNameField] as String? ?? '',
      imageUrl: data[imageUrlField] as String? ?? '',
      role: _byName(
        BannerAudience.values,
        data[roleField],
        BannerAudience.user,
      ),
      status: _byName(
        BannerStatus.values,
        data[statusField],
        BannerStatus.active,
      ),
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }

  static const String roleField = 'role';
  static const String createdAtField = 'createdAt';
  static const String statusField = 'status';
  static const String imageNameField = 'imageName';
  static const String imageUrlField = 'imageUrl';

  final String id;
  final String imageName;
  final String imageUrl;
  final BannerAudience role;
  final BannerStatus status;
  final DateTime? createdAt;

  Map<String, dynamic> toFirestore() => {
    roleField: role.name,
    createdAtField: FieldValue.serverTimestamp(),
    statusField: status.name,
    imageNameField: imageName,
    imageUrlField: imageUrl,
  };

  static int newestFirst(BannerImage a, BannerImage b) {
    final aDate = a.createdAt;
    final bDate = b.createdAt;
    if (aDate == null || bDate == null) {
      return (aDate == null ? 1 : 0) - (bDate == null ? 1 : 0);
    }
    return bDate.compareTo(aDate);
  }

  static T _byName<T extends Enum>(List<T> values, Object? name, T fallback) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
