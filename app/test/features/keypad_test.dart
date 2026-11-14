import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/utils/dates.dart';
import 'package:keuangan_app/engine/common/local_date.dart';
import 'package:keuangan_app/features/transactions/application/keypad.dart';

void main() {
  int type(List<String> keys) => keys.fold(0, applyKeypadKey);

  test('angka, 000, dan hapus', () {
    expect(type(['2', '5', '000']), 25000);
    expect(type(['1', '5', '0', '0', 'del']), 150);
    expect(type(['del']), 0);
    expect(type(['0', '0', '7']), 7);
  });

  test('nominal tidak melebihi 13 digit', () {
    final max = type(List.filled(13, '9'));
    expect(max, 9999999999999);
    expect(applyKeypadKey(max, '1'), max);
    expect(applyKeypadKey(max, '000'), max);
    expect(keypadKeys, hasLength(12));
  });

  test('tanggal transaksi dan jatuh tempo relatif ke hari ini', () {
    final today = LocalDate(2026, 11, 11);
    expect(formatRelativeDay(today, today), 'Hari ini, 11 Nov');
    expect(formatRelativeDay(LocalDate(2026, 11, 10), today), 'Kemarin, 10 Nov');
    expect(formatRelativeDay(LocalDate(2026, 11, 9), today), 'Sen, 9 Nov');

    expect(formatDue(LocalDate(2026, 11, 20), today), '20 Nov · 9 hari lagi');
    expect(formatDue(LocalDate(2026, 11, 12), today), '12 Nov · besok');
    expect(formatDue(today, today), '11 Nov · hari ini');
    expect(formatDue(LocalDate(2026, 11, 9), today), '9 Nov · lewat 2 hari');
  });

  test('judul grup hari dan rentang siklus di layar Transaksi', () {
    final today = LocalDate(2026, 11, 11);
    expect(formatDayHeader(today, today), 'Hari ini · Rab, 11 Nov');
    expect(formatDayHeader(LocalDate(2026, 11, 10), today), 'Kemarin · Sel, 10 Nov');
    expect(formatDayHeader(LocalDate(2026, 11, 9), today), 'Sen, 9 Nov');
    expect(formatDayHeader(LocalDate(2025, 12, 30), today), 'Sel, 30 Des 2025');

    expect(formatDateRange(LocalDate(2026, 10, 25), LocalDate(2026, 11, 24)), '25 Okt – 24 Nov');
    expect(
      formatDateRange(LocalDate(2026, 12, 25), LocalDate(2027, 1, 24)),
      '25 Des 2026 – 24 Jan 2027',
    );
  });
}
