enum PayoutFailureReason {
  invalidAccount('invalidAccount'),
  accountClosed('accountClosed'),
  nameMismatch('nameMismatch'),
  bankRejected('bankRejected'),
  other('other');

  const PayoutFailureReason(this.value);

  final String value;

  bool get needsNote => this == PayoutFailureReason.other;

  static PayoutFailureReason? fromValue(Object? value) {
    for (final reason in values) {
      if (reason.value == value) return reason;
    }
    return null;
  }
}

class PayoutFailureInput {
  const PayoutFailureInput({required this.reason, this.note});

  static const int maxNoteLength = 200;

  final PayoutFailureReason reason;
  final String? note;
}
