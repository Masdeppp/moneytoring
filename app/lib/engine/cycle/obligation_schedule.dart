import 'dart:math' as math;

import '../common/local_date.dart';
import 'pay_cycle.dart';

/// Tanggal jatuh tempo kewajiban bulanan di bulan [month].
///
/// Tanggal 29–31 menjadi hari terakhir di bulan yang lebih pendek. Jatuh tempo
/// tidak digeser karena libur: tagihan tetap dicadangkan per tanggal aslinya.
LocalDate monthlyDueDate(int dueDay, int year, int month) {
  RangeError.checkValueInInterval(dueDay, 1, 31, 'dueDay');
  final firstOfMonth = LocalDate(year, month, 1);
  final lastDay = LocalDate.daysInMonth(firstOfMonth.year, firstOfMonth.month);
  return LocalDate(firstOfMonth.year, firstOfMonth.month, math.min(dueDay, lastDay));
}

/// Semua jatuh tempo bulanan antara [from] dan [to] (keduanya ikut), urut naik.
List<LocalDate> monthlyDueDatesBetween(int dueDay, LocalDate from, LocalDate to) {
  final result = <LocalDate>[];
  var year = from.year;
  var month = from.month;
  while (true) {
    final due = monthlyDueDate(dueDay, year, month);
    if (due > to) return result;
    if (due >= from) result.add(due);
    month++;
    if (month > 12) {
      month = 1;
      year++;
    }
  }
}

/// Jatuh tempo yang dicadangkan dari [cycle]: setelah hari gajian pembuka,
/// paling lambat tepat di hari gajian berikutnya.
///
/// Siklus yang bergeser karena libur bisa memuat dua jatuh tempo atau tidak
/// sama sekali; karena itu instance kewajiban dibuat per tanggal jatuh tempo.
List<LocalDate> dueDatesReservedIn(PayCycle cycle, int dueDay) =>
    monthlyDueDatesBetween(dueDay, cycle.start.addDays(1), cycle.nextPayday);
