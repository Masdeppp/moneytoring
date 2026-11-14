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

/// `20 Apr 2027`, untuk tanggal yang bisa jauh dari hari ini (tenggat target).
String formatDayMonthYear(LocalDate date) => '${formatDayMonth(date)} ${date.year}';

/// `Rab, 25 Nov`
String formatWeekdayDayMonth(LocalDate date) =>
    '${_weekdays[date.weekday - 1]}, ${formatDayMonth(date)}';

/// Tanggal transaksi relatif ke [today]: `Hari ini, 11 Nov`, `Kemarin, 10 Nov`,
/// atau `Sen, 9 Nov`.
String formatRelativeDay(LocalDate date, LocalDate today) => switch (today.differenceInDays(date)) {
  0 => 'Hari ini, ${formatDayMonth(date)}',
  1 => 'Kemarin, ${formatDayMonth(date)}',
  _ => formatWeekdayDayMonth(date),
};

/// Judul grup hari di daftar transaksi: `Hari ini · Rab, 11 Nov`,
/// `Kemarin · Sel, 10 Nov`, `Sen, 9 Nov`, atau `Sel, 30 Des 2025` kalau
/// tahunnya berbeda dari [today].
String formatDayHeader(LocalDate date, LocalDate today) {
  final day = formatWeekdayDayMonth(date);
  return switch (today.differenceInDays(date)) {
    0 => 'Hari ini · $day',
    1 => 'Kemarin · $day',
    _ when date.year != today.year => '$day ${date.year}',
    _ => day,
  };
}

/// Rentang siklus: `25 Okt – 24 Nov`, dengan tahun kalau melewati pergantian
/// tahun (`25 Des 2026 – 24 Jan 2027`).
String formatDateRange(LocalDate first, LocalDate last) => first.year == last.year
    ? '${formatDayMonth(first)} – ${formatDayMonth(last)}'
    : '${formatDayMonth(first)} ${first.year} – ${formatDayMonth(last)} ${last.year}';

/// Jatuh tempo relatif ke [today]: `20 Nov · 9 hari lagi`, `20 Nov · besok`,
/// `20 Nov · hari ini`, atau `20 Nov · lewat 2 hari`.
String formatDue(LocalDate due, LocalDate today) {
  final days = due.differenceInDays(today);
  final when = switch (days) {
    0 => 'hari ini',
    1 => 'besok',
    > 1 => '$days hari lagi',
    _ => 'lewat ${-days} hari',
  };
  return '${formatDayMonth(due)} · $when';
}
