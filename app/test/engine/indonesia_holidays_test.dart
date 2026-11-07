import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/engine/common/local_date.dart';
import 'package:keuangan_app/engine/cycle/indonesia_holidays.dart';
import 'package:keuangan_app/engine/cycle/pay_cycle.dart';

void main() {
  test('jumlah hari libur nasional per tahun sesuai SKB', () {
    int count(int year) => indonesiaNationalHolidayList.where((h) => h.date.year == year).length;

    expect(count(2026), 17);
    expect(count(2027), 18);
    expect(
      indonesiaNationalHolidayList.map((h) => h.date).toSet(),
      hasLength(indonesiaNationalHolidayList.length),
      reason: 'tanggal tidak boleh dobel',
    );
  });

  test('hari dalam minggu cocok dengan yang tertulis di SKB (menangkap salah ketik)', () {
    // 1 = Senin … 7 = Minggu, disalin dari daftar SKB.
    const expectedWeekdays = <String, int>{
      '2026-01-01': 4,
      '2026-01-16': 5,
      '2026-02-17': 2,
      '2026-03-19': 4,
      '2026-03-21': 6,
      '2026-03-22': 7,
      '2026-04-03': 5,
      '2026-04-05': 7,
      '2026-05-01': 5,
      '2026-05-14': 4,
      '2026-05-27': 3,
      '2026-05-31': 7,
      '2026-06-01': 1,
      '2026-06-16': 2,
      '2026-08-17': 1,
      '2026-08-25': 2,
      '2026-12-25': 5,
      '2027-01-01': 5,
      '2027-01-05': 2,
      '2027-02-06': 6,
      '2027-03-08': 1,
      '2027-03-10': 3,
      '2027-03-11': 4,
      '2027-03-26': 5,
      '2027-03-28': 7,
      '2027-05-01': 6,
      '2027-05-06': 4,
      '2027-05-17': 1,
      '2027-05-20': 4,
      '2027-06-01': 2,
      '2027-06-06': 7,
      '2027-08-15': 7,
      '2027-08-17': 2,
      '2027-12-25': 6,
      '2027-12-26': 7,
    };

    final actual = {
      for (final h in indonesiaNationalHolidayList) h.date.toString(): h.date.weekday,
    };
    expect(actual, expectedWeekdays);
  });

  test('gajian yang jatuh di libur nasional maju ke hari kerja sebelumnya', () {
    final calc = PayCycleCalculator(
      PayCycleRule.fixedDate(25),
      holidays: indonesiaNationalHolidays,
    );
    expect(calc.paydayFor(2026, 12), LocalDate(2026, 12, 24)); // Natal, Jumat

    final seventeenth = PayCycleCalculator(
      PayCycleRule.fixedDate(17),
      holidays: indonesiaNationalHolidays,
    );
    expect(seventeenth.paydayFor(2026, 8), LocalDate(2026, 8, 14)); // 17 Agu Senin → Jumat
  });
}
