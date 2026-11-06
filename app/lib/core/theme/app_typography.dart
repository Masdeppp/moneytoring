import 'package:flutter/material.dart';

/// Skala tipografi dari DESIGN.md §2 (Plus Jakarta Sans).
///
/// Font dibundel di `assets/fonts` (variable font) supaya tetap tampil saat
/// offline. Setiap style mengisi `fontWeight` sekaligus sumbu `wght`, karena
/// variable font butuh nilai sumbu yang eksplisit.
abstract final class AppTypography {
  static const fontFamily = 'PlusJakartaSans';

  static const _tabular = <FontFeature>[FontFeature.tabularFigures()];

  static TextStyle _style(
    double size,
    double lineHeight,
    int weight, {
    double tracking = 0,
    bool tabular = false,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: FontWeight.values[weight ~/ 100 - 1],
      fontVariations: [FontVariation('wght', weight.toDouble())],
      letterSpacing: size * tracking,
      fontFeatures: tabular ? _tabular : null,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  /// Angka Safe-to-Spend. Bold 34/42, −2%.
  static final displayAmount = _style(34, 42, 700, tracking: -0.02, tabular: true);
  static final headlineLarge = _style(26, 34, 700, tracking: -0.01);
  static final headlineSmall = _style(20, 28, 700, tracking: -0.005);
  static final titleMedium = _style(16, 24, 600);
  static final titleSmall = _style(14, 20, 600);
  static final bodyLarge = _style(16, 24, 400);
  static final bodyMedium = _style(14, 20, 400);
  static final bodySmall = _style(12, 16, 400);
  static final labelLarge = _style(14, 20, 600, tracking: 0.002);
  static final labelMedium = _style(12, 16, 600, tracking: 0.002);
  static final labelSmall = _style(11, 16, 500, tracking: 0.003);

  /// Label seksi. Teksnya harus ditulis UPPERCASE oleh pemanggil.
  static final overline = _style(11, 16, 700, tracking: 0.06);

  /// Nominal di list. Bold 15/22.
  static final amountMedium = _style(15, 22, 700, tracking: -0.005, tabular: true);

  /// Tombol keypad nominal. Medium 26/34.
  static final keypad = _style(26, 34, 500, tabular: true);

  /// TextTheme Material 3 yang diisi dari skala di atas.
  static TextTheme textTheme({required Color primary, required Color secondary}) {
    return TextTheme(
      headlineLarge: headlineLarge.copyWith(color: primary),
      headlineMedium: headlineLarge.copyWith(color: primary),
      headlineSmall: headlineSmall.copyWith(color: primary),
      titleLarge: headlineSmall.copyWith(color: primary),
      titleMedium: titleMedium.copyWith(color: primary),
      titleSmall: titleSmall.copyWith(color: primary),
      bodyLarge: bodyLarge.copyWith(color: primary),
      bodyMedium: bodyMedium.copyWith(color: primary),
      bodySmall: bodySmall.copyWith(color: secondary),
      labelLarge: labelLarge.copyWith(color: primary),
      labelMedium: labelMedium.copyWith(color: primary),
      labelSmall: labelSmall.copyWith(color: secondary),
    );
  }
}
