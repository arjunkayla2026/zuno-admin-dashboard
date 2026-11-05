import 'package:flutter_test/flutter_test.dart';
import 'package:zuno_admin_dashboard/core/utils/date_formatter.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';

void main() {
  test('grouped uses Indian digit grouping', () {
    expect(NumberFormatter.grouped(49), '49');
    expect(NumberFormatter.grouped(999), '999');
    expect(NumberFormatter.grouped(2648), '2,648');
    expect(NumberFormatter.grouped(245518), '2,45,518');
    expect(NumberFormatter.grouped(1234567), '12,34,567');
  });

  test('rupees adds the symbol and parse reverses formatting', () {
    expect(NumberFormatter.rupees(3142), '₹3,142');
    expect(NumberFormatter.parse('2,098'), 2098);
    expect(NumberFormatter.parse('₹2,45,518'), 245518);
  });

  test('time uses a 12 hour clock', () {
    expect(DateFormatter.time(DateTime(2026, 11, 4, 10, 8)), '10:08 AM');
    expect(DateFormatter.time(DateTime(2026, 11, 4, 0, 5)), '12:05 AM');
    expect(DateFormatter.time(DateTime(2026, 11, 4, 12, 48)), '12:48 PM');
    expect(DateFormatter.time(DateTime(2026, 11, 4, 23, 45)), '11:45 PM');
  });
}
