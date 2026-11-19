import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:zuno_admin_dashboard/core/data/user_record.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/withdrawal.dart';

/// A host's bank beneficiary registration, kept in the `users` document's
/// `hostDetails` map.
///
/// `beneficiaryId` is created the first time the host's row is exported in
/// the beneficiary sheet and stays the same until the approved bank account
/// changes. `beneficiaryBankHash` is a fingerprint of the account it was
/// created for, so no bank details are copied into the user document.
class PayoutBeneficiary {
  const PayoutBeneficiary({required this.id, required this.bankHash});

  static const String idField = 'beneficiaryId';
  static const String isBeneficiaryField = 'isBeneficiary';
  static const String bankHashField = 'beneficiaryBankHash';
  static const String updatedAtField = 'beneficiaryUpdatedAt';

  static const int _randomDigits = 4;
  static final Random _random = Random.secure();
  static int _lastMicros = 0;

  final String id;
  final String bankHash;

  /// The registration stored in [hostDetails], or null when there is none.
  static PayoutBeneficiary? fromHostDetails(Map<String, dynamic> hostDetails) {
    final id = UserRecord.readText(hostDetails[idField]);
    final bankHash = UserRecord.readText(hostDetails[bankHashField]);
    if (id == null || bankHash == null) return null;
    if (hostDetails[isBeneficiaryField] != true) return null;
    return PayoutBeneficiary(id: id, bankHash: bankHash);
  }

  /// The stored beneficiary ID when it still belongs to [account].
  static String? currentId(
    String hostId,
    Map<String, dynamic> hostDetails,
    PayoutBankAccount account,
  ) {
    final stored = fromHostDetails(hostDetails);
    if (stored == null || stored.bankHash != fingerprint(hostId, account)) {
      return null;
    }
    return stored.id;
  }

  static String fingerprint(String hostId, PayoutBankAccount account) {
    String clean(String? value) =>
        (value ?? '').replaceAll(RegExp(r'\s+'), ' ').trim().toUpperCase();
    final key = [
      hostId,
      clean(account.accountNumber).replaceAll(' ', ''),
      clean(account.ifscCode).replaceAll(' ', ''),
      clean(account.accountHolderName),
    ].join('|');
    return sha256.convert(utf8.encode(key)).toString();
  }

  /// A new uniqid-style ID: the current time in microseconds as hex (kept
  /// increasing within a session) followed by random hex digits, uppercase.
  static String generateId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    _lastMicros = now > _lastMicros ? now : _lastMicros + 1;
    final random = _random
        .nextInt(1 << (_randomDigits * 4))
        .toRadixString(16)
        .padLeft(_randomDigits, '0');
    return '${_lastMicros.toRadixString(16)}$random'.toUpperCase();
  }
}
