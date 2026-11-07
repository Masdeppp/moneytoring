import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final _grouped = NumberFormat.decimalPattern('id_ID');

/// Batas 13 digit (Rp 9,9 triliun): cukup untuk keuangan pribadi dan jauh di
/// bawah batas `int`.
const _maxDigits = 13;

/// Memformat isian nominal saat diketik: `1500000` → `1.500.000`.
///
/// Hanya angka yang diterima; titik pemisah ribuan ditambahkan otomatis dan
/// kursor selalu di akhir.
class RupiahInputFormatter extends TextInputFormatter {
  const RupiahInputFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > _maxDigits) return oldValue;
    digits = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final text = digits.isEmpty ? '' : _grouped.format(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// `1.500.000` → `1500000`; kosong → 0.
int parseRupiahInput(String text) {
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.isEmpty ? 0 : int.parse(digits);
}

/// Nilai awal untuk isian nominal: 0 menjadi kosong supaya placeholder terlihat.
String formatRupiahInput(int amount) => amount <= 0 ? '' : _grouped.format(amount);
