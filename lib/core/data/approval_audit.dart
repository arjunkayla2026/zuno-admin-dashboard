import 'package:cloud_firestore/cloud_firestore.dart';

abstract final class ApprovalAudit {
  static const String collection = 'approvalAuditLogs';
  static const String hostRequest = 'hostRequest';
  static const String hostDocument = 'hostDocument';
  static const String profilePhoto = 'profilePhoto';

  static Map<String, Object?> entry({
    required String userId,
    required String adminUid,
    required String type,
    required String status,
    required String previousStatus,
    String? document,
    String? imageUrl,
  }) => {
    'userId': userId,
    'adminUid': adminUid,
    'type': type,
    'status': status,
    'previousStatus': previousStatus,
    'document': ?document,
    'imageUrl': ?imageUrl,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
