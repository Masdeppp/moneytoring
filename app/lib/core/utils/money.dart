import 'package:intl/intl.dart';

// Semua nominal di aplikasi disimpan sebagai `int` dalam Rupiah (PRD §10).
// Fungsi di sini hanya untuk menampilkan, bukan untuk menghitung.

const _minus = '−';
final _grouped = NumberFormat.decimalPattern('id_ID');

/// `Rp 1.250.000`. Negatif memakai tanda minus tipografis: `−Rp 25.000`.
/// Dengan [signed], nilai positif diberi `+` (untuk pemasukan di list).
String formatRupiah(int amount, {bool signed = false}) {
  final body = 'Rp ${_grouped.format(amount.abs())}';
  if (amount < 0) return '$_minus$body';
  if (signed && amount > 0) return '+$body';
  return body;
}

/// Bentuk ringkas untuk ruang sempit: `Rp 2,2 jt`, `Rp 850 rb`, `Rp 1,5 M`.
///
/// Angka dipotong ke bawah (bukan dibulatkan) supaya uang yang tersedia
/// tidak pernah tampil lebih besar dari aslinya.
String formatRupiahCompact(int amount) {
  final abs = amount.abs();
  final (int divisor, String unit) = switch (abs) {
    >= 1000000000 => (1000000000, 'M'),
    >= 1000000 => (1000000, 'jt'),
    >= 1000 => (1000, 'rb'),
    _ => (1, ''),
  };
  if (divisor == 1) return formatRupiah(amount);

  final tenths = abs * 10 ~/ divisor;
  final whole = _grouped.format(tenths ~/ 10);
  final fraction = tenths % 10;
  final number = fraction == 0 ? whole : '$whole,$fraction';
  return '${amount < 0 ? _minus : ''}Rp $number $unit';
}
