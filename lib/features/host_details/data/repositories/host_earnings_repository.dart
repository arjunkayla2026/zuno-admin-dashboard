import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/enums/wallet_adjustment_type.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';
import 'package:zuno_admin_dashboard/core/utils/bank_account_validator.dart';
import 'package:zuno_admin_dashboard/features/approval/data/models/bank_account_record.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/datasources/host_earnings_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/admin_adjustment_totals.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/host_earnings_totals.dart';
import 'package:zuno_admin_dashboard/features/host_details/data/models/wallet_transaction.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/models/admin_host.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/repositories/host_management_repository.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

class HostEarningsRepository {
  const HostEarningsRepository(this._dataSource);

  final HostEarningsRemoteDataSource _dataSource;

  Future<Either<Failure, HostEarningsTotals>> fetchTotals(String hostId) =>
      _dataSource.fetchTotals(hostId);

  /// Admin credit / debit totals added up from the ledger, for hosts whose
  /// `hostEarnings` map does not store them yet.
  Future<Either<Failure, AdminAdjustmentTotals>> fetchLedgerAdjustments(
    String hostId,
  ) => _dataSource.fetchLedgerAdjustments(hostId);

  /// The host as stored now, or null when the document is gone.
  Future<Either<Failure, AdminHost?>> fetchHost(String hostId) async {
    final result = await _dataSource.fetchHostRecord(hostId);
    return result.map(
      (record) =>
          record == null ? null : HostManagementRepository.toAdminHost(record),
    );
  }

  Future<Either<Failure, int>> countWithdrawals(String hostId) =>
      _dataSource.countWithdrawals(hostId);

  Future<Either<Failure, BankAccountRecord?>> fetchBankAccount(String hostId) =>
      _dataSource.fetchBankAccount(hostId);

  Future<Either<Failure, BankAccountRecord>> updateBankAccount(
    BankAccountRecord reviewed,
    BankAccountRecord edited,
  ) async {
    final normalized = edited.copyWith(
      accountHolderName: BankAccountValidator.normalizeName(
        edited.accountHolderName,
      ),
      branchName: BankAccountValidator.normalizeName(edited.branchName),
      accountNumber: BankAccountValidator.normalizeAccountNumber(
        edited.accountNumber,
      ),
      ifscCode: BankAccountValidator.normalizeIfsc(edited.ifscCode),
      panNumber: BankAccountValidator.normalizePan(edited.panNumber),
    );
    final isValid = [
      BankAccountValidator.accountHolderName(normalized.accountHolderName),
      BankAccountValidator.branchName(normalized.branchName),
      BankAccountValidator.accountNumber(normalized.accountNumber),
      BankAccountValidator.ifscCode(normalized.ifscCode),
      BankAccountValidator.panNumber(
        normalized.panNumber,
        required: reviewed.panNumber != null,
      ),
    ].every((error) => error == null);
    if (!isValid) return left(const DataFailure(AppStrings.bankAccountInvalid));
    if (normalized.hasSameDetails(reviewed)) return right(reviewed);

    final result = await _dataSource.updateBankAccount(
      reviewed: reviewed,
      edited: normalized,
    );
    return result.map((_) => normalized.copyWith(updatedAt: DateTime.now()));
  }

  Future<Either<Failure, RecordPage<Withdrawal>>> fetchWithdrawals(
    String hostId, {
    Object? cursor,
  }) async {
    final page = await _dataSource.fetchWithdrawalPage(hostId, cursor: cursor);
    switch (page) {
      case Left():
        return page;
      case Right(value: final loaded)
          when !loaded.items.any((item) => item.needsBankAccountLookup):
        return page;
      case Right(value: final loaded):
        final account = await _dataSource.fetchApprovedBankAccount(hostId);
        return account.map(
          (bankAccount) => loaded.mapItems(
            (items) => [
              for (final item in items)
                item.needsBankAccountLookup
                    ? item.withBankAccount(bankAccount)
                    : item,
            ],
          ),
        );
    }
  }

  Future<Either<Failure, RecordPage<WalletTransaction>>> fetchWallet(
    String hostId, {
    WalletAdjustmentType? type,
    Object? cursor,
  }) => RecordPages.untilMatch(
    cursor,
    (next) => _dataSource.fetchWalletPage(
      hostId,
      types: WalletTransaction.typesFor(type),
      cursor: next,
    ),
    (batch) => batch.where((transaction) => transaction.hasAmount),
  );

  Future<Either<Failure, Unit>> adjust(
    String hostId, {
    required WalletAdjustmentType type,
    required int amount,
    required String description,
    bool isIncentive = false,
  }) => _dataSource.adjust(
    hostId: hostId,
    isCredit: type == WalletAdjustmentType.credit,
    amount: amount,
    description: description,
    isIncentive: isIncentive && type == WalletAdjustmentType.credit,
    requestId: _dataSource.newRequestId(),
  );
}
