import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/model/enums.dart';
import 'package:keuangan_app/engine/common/local_date.dart';
import 'package:keuangan_app/engine/cycle/holiday_calendar.dart';
import 'package:keuangan_app/engine/cycle/obligation_schedule.dart';
import 'package:keuangan_app/engine/cycle/pay_cycle.dart';

LocalDate d(int y, int m, int day) => LocalDate(y, m, day);

void main() {
  group('PayCycleRule', () {
    test('tanggal gajian harus 1–31', () {
      expect(() => PayCycleRule.fixedDate(0), throwsRangeError);
      expect(() => PayCycleRule.fixedDate(32), throwsRangeError);
    });

    test('dibuat dari kolom database', () {
      final fixed = PayCycleRule.fromConfig(
        rule: PaydayRule.fixedDate,
        day: 25,
        shiftOnHoliday: false,
      );
      expect(fixed.rule, PaydayRule.fixedDate);
      expect(fixed.day, 25);
      expect(fixed.shiftOnHoliday, isFalse);

      final last = PayCycleRule.fromConfig(
        rule: PaydayRule.lastWorkday,
        day: null,
        shiftOnHoliday: false,
      );
      expect(last.rule, PaydayRule.lastWorkday);
      expect(last.day, isNull);
    });

    test('fixedDate tanpa tanggal ditolak', () {
      expect(
        () => PayCycleRule.fromConfig(rule: PaydayRule.fixedDate, day: null, shiftOnHoliday: true),
        throwsArgumentError,
      );
    });
  });

  group('paydayFor', () {
    test('tanggal tetap di hari kerja tidak bergeser', () {
      final calc = PayCycleCalculator(PayCycleRule.fixedDate(25));
      expect(calc.paydayFor(2026, 11), d(2026, 11, 25)); // Rabu
    });

    test('tanggal tetap di akhir pekan maju ke Jumat sebelumnya', () {
      final calc = PayCycleCalculator(PayCycleRule.fixedDate(25));
      expect(calc.paydayFor(2026, 10), d(2026, 10, 23)); // 25 Okt = Minggu
    });

    test('tanpa geser, gajian tetap di akhir pekan', () {
      final calc = PayCycleCalculator(PayCycleRule.fixedDate(25, shiftOnHoliday: false));
      expect(calc.paydayFor(2026, 10), d(2026, 10, 25));
    });

    test('tanggal 31 di bulan pendek jadi hari terakhir bulan', () {
      final noShift = PayCycleCalculator(PayCycleRule.fixedDate(31, shiftOnHoliday: false));
      expect(noShift.paydayFor(2026, 4), d(2026, 4, 30));
      expect(noShift.paydayFor(2027, 2), d(2027, 2, 28));

      final shift = PayCycleCalculator(PayCycleRule.fixedDate(31));
      expect(shift.paydayFor(2027, 2), d(2027, 2, 26)); // 28 Feb 2027 = Minggu
    });

    test('libur nasional ikut dilewati', () {
      final calc = PayCycleCalculator(
        PayCycleRule.fixedDate(25),
        holidays: FixedHolidayCalendar([d(2026, 12, 25)]),
      );
      expect(calc.paydayFor(2026, 12), d(2026, 12, 24));
    });

    test('pergeseran bisa melewati batas bulan', () {
      final calc = PayCycleCalculator(PayCycleRule.fixedDate(1));
      expect(calc.paydayFor(2026, 8), d(2026, 7, 31)); // 1 Agu = Sabtu
    });

    test('hari kerja terakhir melewati akhir pekan dan libur', () {
      const calc = PayCycleCalculator(PayCycleRule.lastWorkday());
      expect(calc.paydayFor(2026, 11), d(2026, 11, 30)); // Senin
      expect(calc.paydayFor(2027, 1), d(2027, 1, 29)); // 31 Jan = Minggu

      final withHoliday = PayCycleCalculator(
        const PayCycleRule.lastWorkday(),
        holidays: FixedHolidayCalendar([d(2026, 12, 31)]),
      );
      expect(withHoliday.paydayFor(2026, 12), d(2026, 12, 30));
    });

    test('bulan di luar 1–12 dinormalisasi', () {
      final calc = PayCycleCalculator(PayCycleRule.fixedDate(25));
      expect(calc.paydayFor(2026, 13), calc.paydayFor(2027, 1));
      expect(calc.paydayFor(2027, 0), calc.paydayFor(2026, 12));
    });
  });

  group('cycleContaining', () {
    test('skenario PRD: 11 Nov, gajian 25, tanpa geser', () {
      final calc = PayCycleCalculator(PayCycleRule.fixedDate(25, shiftOnHoliday: false));
      final cycle = calc.cycleContaining(d(2026, 11, 11));

      expect(cycle.start, d(2026, 10, 25));
      expect(cycle.nextPayday, d(2026, 11, 25));
      expect(cycle.end, d(2026, 11, 24));
      expect(cycle.lengthInDays, 31);
      expect(cycle.daysLeft(d(2026, 11, 11)), 14);
      expect(cycle.daysElapsed(d(2026, 11, 11)), 17);
    });

    test('dengan geser, siklus dimulai di Jumat 23 Okt', () {
      final calc = PayCycleCalculator(PayCycleRule.fixedDate(25));
      final cycle = calc.cycleContaining(d(2026, 11, 11));

      expect(cycle, PayCycle(start: d(2026, 10, 23), nextPayday: d(2026, 11, 25)));
      expect(cycle.lengthInDays, 33);
    });

    test('hari gajian membuka siklus baru', () {
      final calc = PayCycleCalculator(PayCycleRule.fixedDate(25));
      final cycle = calc.cycleContaining(d(2026, 11, 25));

      expect(cycle.start, d(2026, 11, 25));
      expect(cycle.nextPayday, d(2026, 12, 25));
      expect(cycle.contains(d(2026, 11, 25)), isTrue);
      expect(cycle.daysElapsed(d(2026, 11, 25)), 0);
    });

    test('sehari sebelum gajian masih siklus lama dengan sisa 1 hari', () {
      final calc = PayCycleCalculator(PayCycleRule.fixedDate(25));
      final cycle = calc.cycleContaining(d(2026, 11, 24));

      expect(cycle.start, d(2026, 10, 23));
      expect(cycle.daysLeft(d(2026, 11, 24)), 1);
      expect(cycle.contains(d(2026, 11, 25)), isFalse);
    });

    test('gajian yang maju ke bulan sebelumnya tetap membuka siklus', () {
      final calc = PayCycleCalculator(PayCycleRule.fixedDate(1));

      expect(
        calc.cycleContaining(d(2026, 7, 30)),
        PayCycle(start: d(2026, 7, 1), nextPayday: d(2026, 7, 31)),
      );
      expect(
        calc.cycleContaining(d(2026, 7, 31)),
        PayCycle(start: d(2026, 7, 31), nextPayday: d(2026, 9, 1)),
      );
      expect(calc.cycleContaining(d(2026, 8, 1)).start, d(2026, 7, 31));
    });

    test('siklus lintas tahun', () {
      final calc = PayCycleCalculator(PayCycleRule.fixedDate(25));
      expect(
        calc.cycleContaining(d(2027, 1, 5)),
        PayCycle(start: d(2026, 12, 25), nextPayday: d(2027, 1, 25)),
      );
    });

    test('siklus berikutnya dan sebelumnya', () {
      final calc = PayCycleCalculator(PayCycleRule.fixedDate(25));
      final cycle = calc.cycleContaining(d(2026, 11, 11));

      expect(calc.nextCycle(cycle), PayCycle(start: d(2026, 11, 25), nextPayday: d(2026, 12, 25)));
      expect(
        calc.previousCycle(cycle),
        PayCycle(start: d(2026, 9, 25), nextPayday: d(2026, 10, 23)),
      );
    });

    test('kewajiban yang jatuh di hari gajian dicadangkan dari siklus sebelumnya', () {
      final calc = PayCycleCalculator(PayCycleRule.fixedDate(25));

      expect(calc.cycleReserving(d(2026, 11, 25)).start, d(2026, 10, 23));
      expect(calc.cycleReserving(d(2026, 10, 23)).start, d(2026, 9, 25));
    });
  });

  group('PayCycle', () {
    test('gajian berikutnya harus setelah awal siklus', () {
      expect(
        () => PayCycle(start: d(2026, 11, 25), nextPayday: d(2026, 11, 25)),
        throwsArgumentError,
      );
    });

    test('toString menampilkan rentang siklus', () {
      final cycle = PayCycle(start: d(2026, 10, 25), nextPayday: d(2026, 11, 25));
      final same = PayCycle(start: d(2026, 10, 25), nextPayday: d(2026, 11, 25));
      expect(cycle.toString(), 'PayCycle(2026-10-25 – 2026-11-24)');
      expect(cycle.hashCode, same.hashCode);
    });
  });

  group('jadwal kewajiban', () {
    test('tanggal 29–31 jadi akhir bulan di bulan pendek', () {
      expect(monthlyDueDate(31, 2026, 2), d(2026, 2, 28));
      expect(monthlyDueDate(31, 2028, 2), d(2028, 2, 29));
      expect(monthlyDueDate(15, 2026, 13), d(2027, 1, 15));
      expect(() => monthlyDueDate(0, 2026, 1), throwsRangeError);
    });

    test('jatuh tempo dalam rentang, kedua ujung ikut', () {
      expect(monthlyDueDatesBetween(20, d(2026, 10, 1), d(2026, 12, 31)), [
        d(2026, 10, 20),
        d(2026, 11, 20),
        d(2026, 12, 20),
      ]);
      expect(monthlyDueDatesBetween(20, d(2026, 10, 20), d(2026, 11, 20)), [
        d(2026, 10, 20),
        d(2026, 11, 20),
      ]);
      expect(monthlyDueDatesBetween(20, d(2026, 12, 21), d(2027, 1, 19)), isEmpty);
    });

    test('siklus PRD mencadangkan jatuh tempo setelah gajian sampai gajian berikutnya', () {
      final cycle = PayCycle(start: d(2026, 10, 25), nextPayday: d(2026, 11, 25));

      expect(dueDatesReservedIn(cycle, 25), [d(2026, 11, 25)]);
      expect(dueDatesReservedIn(cycle, 20), [d(2026, 11, 20)]);
      expect(dueDatesReservedIn(cycle, 1), [d(2026, 11, 1)]);
    });

    test('siklus yang bergeser bisa memuat dua jatuh tempo', () {
      final cycle = PayCycle(start: d(2026, 10, 23), nextPayday: d(2026, 11, 25));
      expect(dueDatesReservedIn(cycle, 24), [d(2026, 10, 24), d(2026, 11, 24)]);
    });

    test('jatuh tempo tidak hilang walau satu siklus tidak memuatnya', () {
      final calc = PayCycleCalculator(
        PayCycleRule.fixedDate(25),
        holidays: FixedHolidayCalendar([d(2026, 12, 25)]),
      );
      final december = calc.cycleContaining(d(2026, 12, 1));
      expect(december, PayCycle(start: d(2026, 11, 25), nextPayday: d(2026, 12, 24)));
      expect(dueDatesReservedIn(december, 25), isEmpty);

      final next = calc.nextCycle(december);
      expect(dueDatesReservedIn(next, 25), [d(2026, 12, 25), d(2027, 1, 25)]);
    });
  });
}
