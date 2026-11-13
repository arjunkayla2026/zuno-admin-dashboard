import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/admins_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/widgets/admin_shell/admin_nav_item.dart';
import 'package:zuno_admin_dashboard/features/approval/data/datasources/payout_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/bank_account_record.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/payout_request.dart';
import 'package:zuno_admin_dashboard/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/repositories/host_management_repository.dart';

class PayoutRepository {
  const PayoutRepository(this._payouts, this._users, this._auth, this._admins);

  final PayoutRemoteDataSource _payouts;
  final UsersRemoteDataSource _users;
  final AuthRemoteDataSource _auth;
  final AdminsRemoteDataSource _admins;

  Future<Either<Failure, RecordPage<PayoutRequest>>> fetchPayoutRequests(
    RecordPageQuery query,
  ) async {
    final accountsResult = await _payouts.fetchSubmitted(query);
    return accountsResult.match(left, (page) async {
      final usersResult = await _users.fetchByIds([
        for (final account in page.items) account.id,
      ]);
      return usersResult.map((users) {
        final usersById = {for (final user in users) user.id: user};
        return page.mapItems(
          (accounts) => [
            for (final account in accounts)
              _toPayout(account, usersById[account.id]),
          ],
        );
      });
    });
  }

  Future<Either<Failure, int>> countPayoutRequests(RecordPageQuery query) =>
      _payouts.countSubmitted(query);

  Future<Either<Failure, Unit>> decide(
    PayoutRequest payout,
    PayoutRequestStatus decision,
  ) async {
    final canReview = await _canReviewPayouts();
    if (canReview case Left(:final value)) return left(value);
    if (!canReview.getOrElse((_) => false)) {
      return left(const DataFailure(AppStrings.recordsWriteDenied));
    }
    return _payouts.decide(
      payout.payoutId,
      approved: decision == PayoutRequestStatus.accepted,
      reviewedAccountNumber: payout.accountNumber,
      reviewedIfscCode: payout.ifscCode,
    );
  }

  Future<Either<Failure, bool>> _canReviewPayouts() async {
    final session = await _auth.restoreSession();
    if (session case Left(:final value)) return left(value);
    final email = session.getOrElse((_) => null)?.email;
    if (email == null) return right(false);

    final account = await _admins.findByEmail(email);
    return account.map(
      (admin) => admin?.canAccess(AdminNavItem.approval) ?? false,
    );
  }

  PayoutRequest _toPayout(BankAccountRecord account, UserRecord? found) {
    final user = found ?? UserRecord(id: account.id);
    final details = user.hostDetails;
    final hostName =
        user.userName ??
        UserRecord.readText(details['userName']) ??
        user.name ??
        AppStrings.emptyValue;
    final location = [
      ?UserRecord.readText(details['district']),
      ?UserRecord.readText(details['state']),
    ].join(', ');

    return PayoutRequest(
      payoutId: account.id,
      submittedOn: account.updatedAt ?? account.createdDate ?? DateTime.now(),
      hostName: hostName,
      hostId: account.id,
      userID: user.userIDLabel,
      realName:
          UserRecord.readText(details['fullName']) ?? user.name ?? hostName,
      phone: user.phoneLabel,
      location: location.isEmpty ? AppStrings.emptyValue : location,
      hostStatus: HostManagementRepository.statusOf(user),
      accountHolderName: account.accountHolderName ?? AppStrings.emptyValue,
      branchName: account.branchName ?? AppStrings.emptyValue,
      accountNumber: account.accountNumber ?? AppStrings.emptyValue,
      ifscCode: account.ifscCode ?? AppStrings.emptyValue,
      avatarIndex: user.avatarIndex,
      approvedAt: account.adminApprovedAt,
      approvedBy: account.adminApprovedBy,
    );
  }
}
