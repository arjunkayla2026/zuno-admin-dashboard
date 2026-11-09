import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';

abstract final class FirestoreFailures {
  static DataFailure read(String code) => DataFailure(switch (code) {
    'permission-denied' || 'unauthenticated' => AppStrings.recordsAccessDenied,
    'unavailable' || 'deadline-exceeded' => AppStrings.recordsNetworkError,
    _ => AppStrings.recordsLoadFailed,
  });

  static DataFailure write(String code) => DataFailure(switch (code) {
    'permission-denied' || 'unauthenticated' => AppStrings.recordsWriteDenied,
    'not-found' => AppStrings.recordNotFound,
    'unavailable' || 'deadline-exceeded' => AppStrings.recordsNetworkError,
    _ => AppStrings.recordsSaveFailed,
  });
}
