import 'package:firebase_core/firebase_core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/app_logger.dart';

abstract final class DataAction {
  static Future<Either<Failure, T>> read<T>(
    String action,
    Future<T> Function() call,
  ) => guard(
    action,
    () async => right(await call()),
    onFirebaseError: (error) => FirestoreFailures.read(error.code),
    fallback: const DataFailure(AppStrings.recordsLoadFailed),
  );

  static Future<Either<Failure, T>> write<T>(
    String action,
    Future<T> Function() call,
  ) => guard(
    action,
    () async => right(await call()),
    onFirebaseError: (error) => FirestoreFailures.write(error.code),
    fallback: const DataFailure(AppStrings.recordsSaveFailed),
  );

  static Future<Either<Failure, T>> guard<T>(
    String action,
    Future<Either<Failure, T>> Function() call, {
    Failure Function(FirebaseException error)? onFirebaseError,
    Failure fallback = const DataFailure(AppStrings.recordsLoadFailed),
  }) async {
    final stopwatch = Stopwatch()..start();
    AppLogger.info('▶ $action');
    try {
      final result = await call();
      final elapsed = stopwatch.elapsedMilliseconds;
      switch (result) {
        case Right(:final value):
          AppLogger.info('✔ $action (${elapsed}ms) ${_describe(value)}');
        case Left(value: final failure):
          AppLogger.info('✖ $action (${elapsed}ms) ${failure.message}');
      }
      return result;
    } on FirebaseException catch (error, stackTrace) {
      AppLogger.error(
        '✖ $action (${stopwatch.elapsedMilliseconds}ms) '
        '[${error.code}] ${error.message}',
        error,
        stackTrace,
      );
      return left(onFirebaseError?.call(error) ?? fallback);
    } catch (error, stackTrace) {
      AppLogger.error(
        '✖ $action (${stopwatch.elapsedMilliseconds}ms) $error',
        error,
        stackTrace,
      );
      return left(fallback);
    }
  }

  static String _describe(Object? value) => switch (value) {
    RecordPage(:final items, :final nextCursor) =>
      'RecordPage(${items.length}, hasMore: ${nextCursor != null})',
    _ => AppLogger.describe(value),
  };
}
