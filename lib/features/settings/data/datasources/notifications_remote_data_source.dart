import 'package:cloud_functions/cloud_functions.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/features/settings/data/models/notification_request.dart';

class NotificationsRemoteDataSource {
  const NotificationsRemoteDataSource(this._functions);

  static const String _sendFunction = 'sendAdminNotification';
  static const Duration _timeout = Duration(minutes: 9);

  final FirebaseFunctions _functions;

  Future<Either<Failure, NotificationSendResult>> send(
    NotificationRequest request,
  ) async {
    try {
      final result = await _functions
          .httpsCallable(
            _sendFunction,
            options: HttpsCallableOptions(timeout: _timeout),
          )
          .call<Map<Object?, Object?>>(request.toPayload());
      return right(NotificationSendResult.fromMap(result.data));
    } on FirebaseFunctionsException catch (error) {
      return left(DataFailure(_messageFor(error)));
    } catch (_) {
      return left(const DataFailure(AppStrings.notificationSendFailed));
    }
  }

  String _messageFor(FirebaseFunctionsException error) => switch (error.code) {
    'unauthenticated' ||
    'permission-denied' => AppStrings.notificationSendDenied,
    'unavailable' || 'deadline-exceeded' => AppStrings.recordsNetworkError,
    'invalid-argument' => error.message ?? AppStrings.notificationSendFailed,
    _ => AppStrings.notificationSendFailed,
  };
}
