import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/engine/common/local_date.dart';

void main() {
  test('menormalkan tanggal di luar rentang seperti DateTime', () {
    expect(LocalDate(2026, 2, 30), LocalDate(2026, 3, 2));
    expect(LocalDate(2026, 13, 1), LocalDate(2027, 1, 1));
    expect(LocalDate(2026, 3, 1).addDays(-1), LocalDate(2026, 2, 28));
  });

  test('jumlah hari per bulan memperhitungkan tahun kabisat', () {
    expect(LocalDate.daysInMonth(2026, 2), 28);
    expect(LocalDate.daysInMonth(2028, 2), 29);
    expect(LocalDate.daysInMonth(2026, 12), 31);
    expect(LocalDate.endOfMonth(2026, 11), LocalDate(2026, 11, 30));
  });

  test('hari dalam minggu dan akhir pekan', () {
    expect(LocalDate(2026, 11, 11).weekday, DateTime.wednesday);
    expect(LocalDate(2026, 11, 11).isWeekend, isFalse);
    expect(LocalDate(2026, 10, 25).isWeekend, isTrue); // Minggu
    expect(LocalDate(2026, 8, 1).isWeekend, isTrue); // Sabtu
  });

  test('selisih hari selalu bilangan bulat, termasuk lintas tahun', () {
    expect(LocalDate(2026, 11, 25).differenceInDays(LocalDate(2026, 11, 11)), 14);
    expect(LocalDate(2026, 11, 11).differenceInDays(LocalDate(2026, 11, 25)), -14);
    expect(LocalDate(2027, 1, 1).differenceInDays(LocalDate(2026, 12, 31)), 1);
  });

  test('konversi dari dan ke DateTime mengabaikan jam', () {
    expect(LocalDate.fromDateTime(DateTime(2026, 11, 11, 23, 59)), LocalDate(2026, 11, 11));
    expect(LocalDate(2026, 11, 11).toDateTime(), DateTime(2026, 11, 11));
  });

  test('kolom tanggal disimpan sebagai UTC tengah malam dan terbaca kembali utuh', () {
    final stored = LocalDate(2026, 11, 1).toUtcMidnight();
    expect(stored, DateTime.utc(2026, 11, 1));
    expect(LocalDate.fromDateTime(stored), LocalDate(2026, 11, 1));
  });

  test('perbandingan, urutan, dan kesetaraan', () {
    final a = LocalDate(2026, 11, 10);
    final b = LocalDate(2026, 11, 11);
    expect(a < b, isTrue);
    expect(a <= b, isTrue);
    expect(b > a, isTrue);
    expect(b >= a, isTrue);
    expect(a <= LocalDate(2026, 11, 10), isTrue);
    expect(a >= LocalDate(2026, 11, 10), isTrue);
    expect([b, a]..sort(), [a, b]);
    expect({a, LocalDate(2026, 11, 10)}, hasLength(1));
    expect(a == b, isFalse);
  });

  test('toString berformat ISO', () {
    expect(LocalDate(2026, 11, 7).toString(), '2026-11-07');
  });
}
