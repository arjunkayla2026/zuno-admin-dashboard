import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';

/// Finds profile pictures for screens that only know a user or host ID
/// (withdrawals, reports, call details).
///
/// IDs requested in the same frame are read together in one batched `users`
/// query, and each answer is kept for the session, so scrolling back or
/// opening another screen with the same people costs no extra reads.
class ProfilePhotoLookup {
  ProfilePhotoLookup(this._users);

  final UsersRemoteDataSource _users;
  final Map<String, ValueNotifier<String?>> _photos = {};
  final Set<String> _queued = {};
  bool _flushScheduled = false;

  /// The profile picture of [userId]; null until it is found, or when the
  /// person has none.
  ValueListenable<String?> photoOf(String userId) {
    final known = _photos[userId];
    if (known != null) return known;
    final photo = _photos[userId] = ValueNotifier(null);
    if (userId.isNotEmpty) _queue(userId);
    return photo;
  }

  void _queue(String userId) {
    _queued.add(userId);
    if (_flushScheduled) return;
    _flushScheduled = true;
    scheduleMicrotask(_flush);
  }

  Future<void> _flush() async {
    _flushScheduled = false;
    final ids = _queued.toList();
    _queued.clear();
    final result = await _users.fetchByIds(ids);
    result.match(
      // Forget the IDs so a later screen can try again.
      (_) => ids.forEach(_photos.remove),
      (records) {
        for (final record in records) {
          _photos[record.id]?.value = record.profileImageUrl;
        }
      },
    );
  }
}
