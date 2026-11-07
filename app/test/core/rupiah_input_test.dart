import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/utils/dates.dart';
import 'package:keuangan_app/core/utils/rupiah_input.dart';
import 'package:keuangan_app/engine/common/local_date.dart';

void main() {
  const formatter = RupiahInputFormatter();

  TextEditingValue type(String text, {String old = ''}) => formatter.formatEditUpdate(
    TextEditingValue(text: old),
    TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    ),
  );

  test('titik ribuan ditambahkan saat mengetik, kursor di akhir', () {
    final value = type('1500000');
    expect(value.text, '1.500.000');
    expect(value.selection.baseOffset, value.text.length);
  });

  test('karakter selain angka dan nol di depan dibuang', () {
    expect(type('Rp 2.500abc').text, '2.500');
    expect(type('0007').text, '7');
    expect(type('0').text, '0');
    expect(type('').text, '');
  });

  test('lebih dari 13 digit ditolak, isian lama dipertahankan', () {
    const old = '9.999.999.999.999';
    expect(type('99999999999999', old: old).text, old);
  });

  test('parse dan nilai awal', () {
    expect(parseRupiahInput('1.500.000'), 1500000);
    expect(parseRupiahInput(''), 0);
    expect(formatRupiahInput(0), '');
    expect(formatRupiahInput(850000), '850.000');
  });

  test('tanggal pendek berbahasa Indonesia', () {
    expect(formatDayMonth(LocalDate(2026, 11, 25)), '25 Nov');
    expect(formatWeekdayDayMonth(LocalDate(2026, 11, 25)), 'Rab, 25 Nov');
    expect(formatWeekdayDayMonth(LocalDate(2026, 5, 31)), 'Min, 31 Mei');
  });
}
