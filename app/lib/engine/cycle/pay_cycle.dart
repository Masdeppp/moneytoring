import 'dart:math' as math;

import '../../core/model/enums.dart';
import '../common/local_date.dart';
import 'holiday_calendar.dart';

/// Aturan gajian pengguna, padanan baris tabel `pay_cycle_configs`.
final class PayCycleRule {
  /// Gajian tiap tanggal [day] (1–31). Tanggal 29–31 menjadi hari terakhir
  /// di bulan yang lebih pendek.
  PayCycleRule.fixedDate(int day, {this.shiftOnHoliday = true})
    : rule = PaydayRule.fixedDate,
      day = RangeError.checkValueInInterval(day, 1, 31, 'day');

  /// Gajian di hari kerja terakhir tiap bulan.
  const PayCycleRule.lastWorkday()
    : rule = PaydayRule.lastWorkday,
      day = null,
      shiftOnHoliday = true;

  /// Dari kolom database. `fixedDate` wajib punya [day].
  factory PayCycleRule.fromConfig({
    required PaydayRule rule,
    required int? day,
    required bool shiftOnHoliday,
  }) => switch (rule) {
    PaydayRule.fixedDate => PayCycleRule.fixedDate(
      day ?? (throw ArgumentError.notNull('day')),
      shiftOnHoliday: shiftOnHoliday,
    ),
    PaydayRule.lastWorkday => const PayCycleRule.lastWorkday(),
  };

  final PaydayRule rule;
  final int? day;

  /// Untuk `fixedDate`: geser ke hari kerja sebelumnya kalau gajian jatuh di
  /// akhir pekan atau libur nasional.
  final bool shiftOnHoliday;
}

/// Satu siklus gajian: dari hari gajian sampai sehari sebelum gajian berikutnya.
final class PayCycle {
  PayCycle({required this.start, required this.nextPayday}) {
    if (nextPayday <= start) {
      throw ArgumentError('nextPayday ($nextPayday) harus setelah start ($start)');
    }
  }

  /// Hari gajian yang membuka siklus ini (ikut siklus).
  final LocalDate start;

  /// Hari gajian berikutnya (sudah siklus baru).
  final LocalDate nextPayday;

  /// Hari terakhir siklus.
  LocalDate get end => nextPayday.addDays(-1);

  int get lengthInDays => nextPayday.differenceInDays(start);

  bool contains(LocalDate date) => date >= start && date < nextPayday;

  /// Hari tersisa sampai gajian berikutnya; 1 di hari terakhir siklus.
  int daysLeft(LocalDate today) => nextPayday.differenceInDays(today);

  /// Hari yang sudah lewat sejak awal siklus; 0 di hari gajian.
  int daysElapsed(LocalDate today) => today.differenceInDays(start);

  @override
  bool operator ==(Object other) =>
      other is PayCycle && other.start == start && other.nextPayday == nextPayday;

  @override
  int get hashCode => Object.hash(start, nextPayday);

  @override
  String toString() => 'PayCycle($start – $end)';
}

/// Menghitung tanggal gajian dan siklus dari [rule].
final class PayCycleCalculator {
  const PayCycleCalculator(this.rule, {this.holidays = const NoHolidays()});

  final PayCycleRule rule;
  final HolidayCalendar holidays;

  /// Hari gajian efektif untuk bulan [month] (boleh di luar 1–12; dinormalisasi).
  ///
  /// Karena digeser mundur, hasilnya bisa jatuh di bulan sebelumnya, mis.
  /// gajian tanggal 1 yang jatuh di hari Sabtu dibayar Jumat sebelumnya.
  LocalDate paydayFor(int year, int month) {
    final firstOfMonth = LocalDate(year, month, 1);
    final y = firstOfMonth.year;
    final m = firstOfMonth.month;
    switch (rule.rule) {
      case PaydayRule.fixedDate:
        final nominal = LocalDate(y, m, math.min(rule.day!, LocalDate.daysInMonth(y, m)));
        return rule.shiftOnHoliday ? workdayOnOrBefore(nominal, holidays) : nominal;
      case PaydayRule.lastWorkday:
        return workdayOnOrBefore(LocalDate.endOfMonth(y, m), holidays);
    }
  }

  /// Siklus yang memuat [date].
  PayCycle cycleContaining(LocalDate date) {
    // Gajian bulan lalu pasti sudah lewat, karena hanya bisa bergeser mundur.
    var start = paydayFor(date.year, date.month - 1);
    var offset = 0;
    while (true) {
      final payday = paydayFor(date.year, date.month + offset);
      if (payday > date) return PayCycle(start: start, nextPayday: payday);
      start = payday;
      offset++;
    }
  }

  PayCycle nextCycle(PayCycle cycle) => cycleContaining(cycle.nextPayday);

  PayCycle previousCycle(PayCycle cycle) => cycleContaining(cycle.start.addDays(-1));

  /// Siklus yang mencadangkan kewajiban yang jatuh tempo di [dueDate].
  ///
  /// Kewajiban dicadangkan dari siklus sebelum jatuh tempo, termasuk yang jatuh
  /// tepat di hari gajian (lihat docs/FASE1.md §2).
  PayCycle cycleReserving(LocalDate dueDate) => cycleContaining(dueDate.addDays(-1));
}
