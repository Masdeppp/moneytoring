import '../common/local_date.dart';

/// Sumber hari libur nasional untuk menggeser tanggal gajian.
///
/// Akhir pekan tidak perlu dimasukkan; [isWorkday] sudah memperhitungkannya.
abstract interface class HolidayCalendar {
  bool isHoliday(LocalDate date);
}

/// Tanpa libur nasional: hanya akhir pekan yang dilewati.
final class NoHolidays implements HolidayCalendar {
  const NoHolidays();

  @override
  bool isHoliday(LocalDate date) => false;
}

/// Daftar libur nasional yang sudah diketahui, mis. dari SKB 3 Menteri.
final class FixedHolidayCalendar implements HolidayCalendar {
  FixedHolidayCalendar(Iterable<LocalDate> holidays) : _holidays = Set.unmodifiable(holidays);

  final Set<LocalDate> _holidays;

  @override
  bool isHoliday(LocalDate date) => _holidays.contains(date);
}

/// Hari kerja = Senin–Jumat dan bukan libur nasional.
bool isWorkday(LocalDate date, HolidayCalendar holidays) =>
    !date.isWeekend && !holidays.isHoliday(date);

/// Hari kerja terdekat pada atau sebelum [date].
LocalDate workdayOnOrBefore(LocalDate date, HolidayCalendar holidays) {
  var current = date;
  while (!isWorkday(current, holidays)) {
    current = current.addDays(-1);
  }
  return current;
}
