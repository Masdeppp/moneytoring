import '../../engine/common/local_date.dart';

// Nama hari dan bulan ditulis langsung supaya tidak bergantung pada data
// locale `intl` yang harus dimuat dulu (dan tidak ada di widget test).

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];
const _weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

/// `25 Nov`
String formatDayMonth(LocalDate date) => '${date.day} ${_months[date.month - 1]}';

/// `Rab, 25 Nov`
String formatWeekdayDayMonth(LocalDate date) =>
    '${_weekdays[date.weekday - 1]}, ${formatDayMonth(date)}';
