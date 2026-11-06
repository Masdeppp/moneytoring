import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/utils/money.dart';

void main() {
  group('formatRupiah', () {
    test('memakai titik sebagai pemisah ribuan', () {
      expect(formatRupiah(0), 'Rp 0');
      expect(formatRupiah(25000), 'Rp 25.000');
      expect(formatRupiah(1250000), 'Rp 1.250.000');
    });

    test('negatif memakai tanda minus tipografis', () {
      expect(formatRupiah(-25000), '−Rp 25.000');
    });

    test('signed memberi tanda plus hanya untuk nilai positif', () {
      expect(formatRupiah(7500000, signed: true), '+Rp 7.500.000');
      expect(formatRupiah(0, signed: true), 'Rp 0');
      expect(formatRupiah(-1, signed: true), '−Rp 1');
    });
  });

  group('formatRupiahCompact', () {
    test('memakai satuan rb, jt, dan M', () {
      expect(formatRupiahCompact(999), 'Rp 999');
      expect(formatRupiahCompact(1000), 'Rp 1 rb');
      expect(formatRupiahCompact(850000), 'Rp 850 rb');
      expect(formatRupiahCompact(2200000), 'Rp 2,2 jt');
      expect(formatRupiahCompact(1500000000), 'Rp 1,5 M');
      expect(formatRupiahCompact(1500000000000), 'Rp 1.500 M');
    });

    test('memotong ke bawah supaya tidak melebih-lebihkan', () {
      expect(formatRupiahCompact(2250000), 'Rp 2,2 jt');
      expect(formatRupiahCompact(1999999), 'Rp 1,9 jt');
    });

    test('negatif tetap diberi tanda minus', () {
      expect(formatRupiahCompact(-150000), '−Rp 150 rb');
    });
  });
}
