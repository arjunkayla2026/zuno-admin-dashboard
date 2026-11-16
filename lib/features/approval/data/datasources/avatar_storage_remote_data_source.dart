import 'dart:math' as math;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';

class AvatarStorageRemoteDataSource {
  AvatarStorageRemoteDataSource(this._storage, {math.Random? random})
    : _random = random ?? math.Random();

  static const int _maxAttempts = 3;
  static const String _hiddenFilePrefix = '.';

  final FirebaseStorage _storage;
  final math.Random _random;
  final Map<String, List<String>> _recentPicks = {};

  Future<Either<Failure, String>> pickRandomAvatarUrl(
    String folder, {
    String? avoidUrl,
  }) async {
    try {
      final listing = await _storage.ref(folder).listAll();
      final paths = [
        for (final item in listing.items)
          if (!item.name.startsWith(_hiddenFilePrefix)) item.fullPath,
      ];
      if (paths.isEmpty) {
        return left(const DataFailure(AppStrings.avatarFolderEmpty));
      }

      final recent = _recentPicks.putIfAbsent(folder, () => []);
      final current = UserRecord.storagePathOf(avoidUrl);
      final candidates = _candidates(
        paths,
        avoid: {?current, ...recent},
        current: current,
      )..shuffle(_random);

      Failure? lastFailure;
      for (final path in candidates.take(_maxAttempts)) {
        final url = await _downloadUrl(path);
        switch (url) {
          case Right(:final value):
            _remember(recent, path, available: paths.length);
            return right(value);
          case Left(:final value):
            lastFailure = value;
        }
      }
      return left(
        lastFailure ?? const DataFailure(AppStrings.avatarLoadFailed),
      );
    } on FirebaseException catch (error) {
      return left(_failure(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.avatarLoadFailed));
    }
  }

  static List<String> _candidates(
    List<String> paths, {
    required Set<String> avoid,
    required String? current,
  }) {
    final fresh = [
      for (final path in paths)
        if (!avoid.contains(path)) path,
    ];
    if (fresh.isNotEmpty) return fresh;

    final notCurrent = [
      for (final path in paths)
        if (path != current) path,
    ];
    return notCurrent.isNotEmpty ? notCurrent : [...paths];
  }

  Future<Either<Failure, String>> _downloadUrl(String path) async {
    try {
      final url = await _storage.ref(path).getDownloadURL();
      return UserRecord.isWebUrl(url) && UserRecord.isDefaultAvatarUrl(url)
          ? right(url)
          : left(const DataFailure(AppStrings.avatarLoadFailed));
    } on FirebaseException catch (error) {
      return left(_failure(error.code));
    } catch (_) {
      return left(const DataFailure(AppStrings.avatarLoadFailed));
    }
  }

  static void _remember(
    List<String> recent,
    String path, {
    required int available,
  }) {
    recent
      ..remove(path)
      ..add(path);
    while (recent.isNotEmpty && recent.length >= available) {
      recent.removeAt(0);
    }
  }

  static DataFailure _failure(String code) => DataFailure(switch (code) {
    'unauthorized' || 'unauthenticated' => AppStrings.avatarAccessDenied,
    'retry-limit-exceeded' => AppStrings.recordsNetworkError,
    _ => AppStrings.avatarLoadFailed,
  });
}
