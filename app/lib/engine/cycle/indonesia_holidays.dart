import '../common/local_date.dart';
import 'holiday_calendar.dart';

/// Hari libur nasional Indonesia menurut SKB 3 Menteri (Menag, Menaker, MenPAN-RB).
///
/// - 2026: SKB No. 1497/2025, 2/2025, 5/2025 (19 Sep 2025) — 17 hari.
/// - 2027: SKB No. 1205/2026, 3/2026, 2/2026 (15 Sep 2026) — 18 hari.
///
/// Cuti bersama sengaja tidak dimasukkan. Tidak semua kantor dan bank libur
/// di hari itu, dan gajian yang tetap di tanggal aslinya membuat siklus lebih
/// panjang, sehingga Safe-to-Spend lebih konservatif.
///
/// Tambahkan tahun berikutnya setiap SKB baru terbit (biasanya September),
/// lalu perbarui test di `test/engine/indonesia_holidays_test.dart`.
final List<({LocalDate date, String name})> indonesiaNationalHolidayList = [
  // 2026
  (date: LocalDate(2026, 1, 1), name: 'Tahun Baru 2026 Masehi'),
  (date: LocalDate(2026, 1, 16), name: 'Isra Mikraj Nabi Muhammad SAW'),
  (date: LocalDate(2026, 2, 17), name: 'Tahun Baru Imlek 2577 Kongzili'),
  (date: LocalDate(2026, 3, 19), name: 'Hari Suci Nyepi (Tahun Baru Saka 1948)'),
  (date: LocalDate(2026, 3, 21), name: 'Idul Fitri 1447 H (hari pertama)'),
  (date: LocalDate(2026, 3, 22), name: 'Idul Fitri 1447 H (hari kedua)'),
  (date: LocalDate(2026, 4, 3), name: 'Wafat Yesus Kristus'),
  (date: LocalDate(2026, 4, 5), name: 'Kebangkitan Yesus Kristus (Paskah)'),
  (date: LocalDate(2026, 5, 1), name: 'Hari Buruh Internasional'),
  (date: LocalDate(2026, 5, 14), name: 'Kenaikan Yesus Kristus'),
  (date: LocalDate(2026, 5, 27), name: 'Idul Adha 1447 H'),
  (date: LocalDate(2026, 5, 31), name: 'Hari Raya Waisak 2570 BE'),
  (date: LocalDate(2026, 6, 1), name: 'Hari Lahir Pancasila'),
  (date: LocalDate(2026, 6, 16), name: 'Tahun Baru Islam 1448 H'),
  (date: LocalDate(2026, 8, 17), name: 'Proklamasi Kemerdekaan RI'),
  (date: LocalDate(2026, 8, 25), name: 'Maulid Nabi Muhammad SAW'),
  (date: LocalDate(2026, 12, 25), name: 'Kelahiran Yesus Kristus (Natal)'),
  // 2027
  (date: LocalDate(2027, 1, 1), name: 'Tahun Baru 2027 Masehi'),
  (date: LocalDate(2027, 1, 5), name: 'Isra Mikraj Nabi Muhammad SAW'),
  (date: LocalDate(2027, 2, 6), name: 'Tahun Baru Imlek 2578 Kongzili'),
  (date: LocalDate(2027, 3, 8), name: 'Hari Suci Nyepi (Tahun Baru Saka 1949)'),
  (date: LocalDate(2027, 3, 10), name: 'Idul Fitri 1448 H (hari pertama)'),
  (date: LocalDate(2027, 3, 11), name: 'Idul Fitri 1448 H (hari kedua)'),
  (date: LocalDate(2027, 3, 26), name: 'Wafat Yesus Kristus'),
  (date: LocalDate(2027, 3, 28), name: 'Kebangkitan Yesus Kristus (Paskah)'),
  (date: LocalDate(2027, 5, 1), name: 'Hari Buruh Internasional'),
  (date: LocalDate(2027, 5, 6), name: 'Kenaikan Yesus Kristus'),
  (date: LocalDate(2027, 5, 17), name: 'Idul Adha 1448 H'),
  (date: LocalDate(2027, 5, 20), name: 'Hari Raya Waisak 2571 BE'),
  (date: LocalDate(2027, 6, 1), name: 'Hari Lahir Pancasila'),
  (date: LocalDate(2027, 6, 6), name: 'Tahun Baru Islam 1449 H'),
  (date: LocalDate(2027, 8, 15), name: 'Maulid Nabi Muhammad SAW'),
  (date: LocalDate(2027, 8, 17), name: 'Proklamasi Kemerdekaan RI'),
  (date: LocalDate(2027, 12, 25), name: 'Kelahiran Yesus Kristus (Natal)'),
  // Isra Mikraj 1449 H jatuh lagi di akhir tahun yang sama.
  (date: LocalDate(2027, 12, 26), name: 'Isra Mikraj Nabi Muhammad SAW'),
];

/// Kalender libur nasional untuk menggeser tanggal gajian.
final HolidayCalendar indonesiaNationalHolidays = FixedHolidayCalendar(
  indonesiaNationalHolidayList.map((holiday) => holiday.date),
);
