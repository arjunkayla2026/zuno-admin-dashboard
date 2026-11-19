import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:zuno_admin_dashboard/core/data/payout_settings.dart';
import 'package:zuno_admin_dashboard/features/payment/data/models/payout_sheet_row.dart';

/// Builds the bank's bulk upload workbooks (beneficiary registration and
/// NEFT withdrawal) from pending payouts.
///
/// Every value is written as text, as in the bank's templates, so account
/// numbers, phone numbers and codes keep their leading zeros.
class PayoutSheetExporter {
  const PayoutSheetExporter._();

  // TODO(payment): replace with the company's bank details before use.
  static const String customerId = '';
  static const String debitAccountNumber = '';

  static const String accountType = 'SAVINGS';
  static const String transactionType = 'NEFT';
  static const String mimeType =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  static const String _sheetName = 'Sheet1';
  static const String _remarksSeparator = '; ';
  static const int _mobileDigits = 10;
  static const double _columnWidth = 22;

  static final ExcelColor _beneficiaryHeader = ExcelColor.fromHexString(
    '#FFFF00',
  );
  static final ExcelColor _withdrawalHeader = ExcelColor.fromHexString(
    '#00B0F0',
  );

  static const List<String> beneficiaryColumns = [
    'Customer ID',
    'Beneficiary Code',
    'Beneficiary Name',
    'Account Number',
    'IFSC Code',
    'Account Type',
    'Mobile Number',
    'Email ID(For Alert)',
    'ADDRESS1',
    'ADDRESS2',
    'ADDRESS3',
    'ADDRESS4',
    'ZIP Code',
  ];

  static const List<String> withdrawalColumns = [
    'Transaction Type',
    'Debit Account Number',
    'Transaction Amount',
    'Value Date',
    'Beneficiary Account Number',
    'Beneficiary Name',
    'IFSC Code',
    'Beneficiary Email ID',
    'Beneficiary ID',
    'Credit Remarks',
    'Debit Remarks',
    'Unique Customer Reference Number',
  ];

  static Uint8List beneficiaries(List<PayoutSheetRow> rows) =>
      _build(beneficiaryColumns, _beneficiaryHeader, [
        for (final row in rows)
          [
            customerId,
            row.withdrawal.hostUserId,
            _beneficiaryName(row),
            row.bankAccount.accountNumber ?? '',
            row.bankAccount.ifscCode ?? '',
            accountType,
            _mobile(row.withdrawal.phoneNumber),
            '',
            '',
            '',
            row.district ?? '',
            row.state ?? '',
            '',
          ],
      ]);

  static Uint8List withdrawals(List<PayoutSheetRow> rows, DateTime valueDate) =>
      _build(withdrawalColumns, _withdrawalHeader, [
        for (final row in rows)
          [
            transactionType,
            debitAccountNumber,
            row.withdrawal
                .receivableAmount(PayoutSettings.tdsPercent)
                .toStringAsFixed(2),
            _date(valueDate),
            row.bankAccount.accountNumber ?? '',
            _beneficiaryName(row),
            row.bankAccount.ifscCode ?? '',
            '',
            row.withdrawal.hostUserId,
            _remarks(row.remarks.credit),
            _remarks(row.remarks.debit),
            row.withdrawal.bankReference,
          ],
      ]);

  static Uint8List _build(
    List<String> columns,
    ExcelColor headerColor,
    List<List<String>> rows,
  ) {
    final excel = Excel.createExcel();
    final sheet = excel[_sheetName];
    final headerStyle = CellStyle(bold: true, backgroundColorHex: headerColor);
    for (var column = 0; column < columns.length; column++) {
      sheet
        ..updateCell(
          CellIndex.indexByColumnRow(columnIndex: column, rowIndex: 0),
          TextCellValue(columns[column]),
          cellStyle: headerStyle,
        )
        ..setColumnWidth(column, _columnWidth);
    }
    for (final row in rows) {
      sheet.appendRow([for (final value in row) TextCellValue(value)]);
    }
    return Uint8List.fromList(excel.encode() ?? const []);
  }

  static String _beneficiaryName(PayoutSheetRow row) =>
      row.bankAccount.accountHolderName ??
      row.fullName ??
      row.withdrawal.hostName;

  static String _mobile(String? phoneNumber) {
    final digits = (phoneNumber ?? '').replaceAll(RegExp(r'\D'), '');
    return digits.length > _mobileDigits
        ? digits.substring(digits.length - _mobileDigits)
        : digits;
  }

  static String _date(DateTime date) =>
      '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static String _remarks(List<String> remarks) => remarks
      .map((remark) => remark.replaceAll(RegExp(r'\s+'), ' ').trim())
      .where((remark) => remark.isNotEmpty)
      .join(_remarksSeparator);
}
