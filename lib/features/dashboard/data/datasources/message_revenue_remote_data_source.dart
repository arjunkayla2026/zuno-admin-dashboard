import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/data_action.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';

/// Admin revenue from paid chat messages.
///
/// The calling app's `sendChatMessage` function charges only messages a user
/// sends to a host, takes `coinsCharged / 15` rupees from the user's wallet and
/// keeps all of it for the platform (hosts get no share). Each message is
/// stored at `chats/{conversationId}/messages/{messageId}` with `coinsCharged`
/// and `createdAt`; host replies have `coinsCharged` 0.
class MessageRevenueRemoteDataSource {
  const MessageRevenueRemoteDataSource(this._firestore);

  static const String messagesCollectionGroup = 'messages';
  static const String coinsChargedField = 'coinsCharged';
  static const String createdAtField = 'createdAt';

  /// Lower bound used for All Dates, so every range runs on the same
  /// `createdAt` + `coinsCharged` collection group index.
  static final DateTime _earliest = DateTime.utc(2000);

  final FirebaseFirestore _firestore;

  /// Rupees charged for messages created in the range, unrounded so the
  /// dashboard total is rounded only once.
  Future<Either<Failure, double>> fetchRevenue({
    DateTime? from,
    DateTime? until,
  }) => DataAction.read('messages.fetchRevenue', () async {
    Query<Map<String, dynamic>> query = _firestore
        .collectionGroup(messagesCollectionGroup)
        .where(
          createdAtField,
          isGreaterThanOrEqualTo: Timestamp.fromDate(from ?? _earliest),
        );
    if (until != null) {
      query = query.where(
        createdAtField,
        isLessThan: Timestamp.fromDate(until),
      );
    }
    final snapshot = await query.aggregate(sum(coinsChargedField)).get();
    return (snapshot.getSum(coinsChargedField) ?? 0) /
        PackagePlan.coinsPerRupee;
  });
}
