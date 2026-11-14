import 'dart:ui';

/// Warna primitif dari DESIGN.md §1.1.
///
/// Jangan dipakai langsung di widget. Pakai token semantik di `AppColors`
/// (`context.colors.*`) supaya Light dan Dark otomatis benar.
abstract final class Palette {
  static const brand50 = Color(0xFFEAFBF4);
  static const brand100 = Color(0xFFCDF5E3);
  static const brand200 = Color(0xFF9DEACB);
  static const brand300 = Color(0xFF5FD8AE);
  static const brand400 = Color(0xFF2CC290);
  static const brand500 = Color(0xFF12A679);
  static const brand600 = Color(0xFF0A8763);
  static const brand700 = Color(0xFF0B6C52);
  static const brand800 = Color(0xFF0D5643);
  static const brand900 = Color(0xFF0B4738);
  static const brand950 = Color(0xFF04281F);

  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral50 = Color(0xFFF6F8F7);
  static const neutral100 = Color(0xFFEDF1EF);
  static const neutral200 = Color(0xFFDCE2DF);
  static const neutral300 = Color(0xFFBFC8C4);
  static const neutral400 = Color(0xFF919D98);
  // Sedikit lebih gelap dari desain awal (#6A7671) supaya teks tersier di
  // kanvas lulus WCAG AA (4,6:1). Diperiksa 9 Nov 2026.
  static const neutral500 = Color(0xFF67736E);
  static const neutral600 = Color(0xFF4E5955);
  static const neutral700 = Color(0xFF39423F);
  static const neutral800 = Color(0xFF242B29);
  static const neutral900 = Color(0xFF161B1A);
  static const neutral950 = Color(0xFF0C100F);

  static const amber50 = Color(0xFFFFF7E6);
  static const amber100 = Color(0xFFFEEBC2);
  static const amber400 = Color(0xFFF7BD4F);
  static const amber500 = Color(0xFFF0A020);
  static const amber600 = Color(0xFFCC8008);
  static const amber700 = Color(0xFF9E6106);

  /// Kartu Waspada (terang) dan ikon/teks tone amber: amber/700 tidak cukup
  /// kontras untuk teks putih 72% dan badge.
  static const amber800 = Color(0xFF7B4C05);
  static const amber900 = Color(0xFF3A2604);

  static const red50 = Color(0xFFFEF1F1);
  static const red100 = Color(0xFFFDDCDC);
  static const red400 = Color(0xFFF27A7D);
  static const red500 = Color(0xFFE34A4F);
  static const red600 = Color(0xFFC8323A);
  static const red700 = Color(0xFFA1252C);
  static const red900 = Color(0xFF3B1215);

  static const blue50 = Color(0xFFEEF5FF);
  static const blue100 = Color(0xFFDCE9FE);
  static const blue400 = Color(0xFF6FA0F5);
  static const blue500 = Color(0xFF3B7DF0);
  // #2563D6 → #2461D2 supaya badge biru lulus AA di blue/100.
  static const blue600 = Color(0xFF2461D2);
  static const blue900 = Color(0xFF10264D);

  static const violet50 = Color(0xFFF4F0FF);
  static const violet100 = Color(0xFFE6DEFF);
  static const violet400 = Color(0xFFA48BF0);
  static const violet500 = Color(0xFF7C5CE6);
  static const violet600 = Color(0xFF6544CC);
  static const violet900 = Color(0xFF261A52);

  /// Garis tepi input dan chip: minimal 3:1 terhadap latarnya (WCAG 1.4.11).
  static const borderStrongLight = Color(0xFF86908C);
  static const borderStrongDark = Color(0xFF6C7572);

  /// `alpha/white-72`: putih 72%.
  static const white72 = Color(0xB8FFFFFF);

  /// `alpha/white-16`: putih 16%.
  static const white16 = Color(0x29FFFFFF);

  /// `alpha/scrim`: neutral/950 48%.
  static const scrim = Color(0x7A0C100F);
}
