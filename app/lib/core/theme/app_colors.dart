import 'package:flutter/material.dart';

import '../model/enums.dart';
import 'app_palette.dart';

/// Pasangan warna latar + isi untuk satu [Tone] (tile kategori, badge).
@immutable
class ToneColors {
  const ToneColors({required this.bg, required this.fg});

  final Color bg;
  final Color fg;

  static ToneColors lerp(ToneColors a, ToneColors b, double t) =>
      ToneColors(bg: Color.lerp(a.bg, b.bg, t)!, fg: Color.lerp(a.fg, b.fg, t)!);

  @override
  bool operator ==(Object other) => other is ToneColors && other.bg == bg && other.fg == fg;

  @override
  int get hashCode => Object.hash(bg, fg);
}

/// Token warna semantik dari DESIGN.md §1.2, dengan nilai Light dan Dark.
///
/// Akses lewat `context.colors` (lihat `theme_context.dart`).
/// Nama mengikuti code syntax Figma: `bg/hero-safe` → [bgHeroSafe].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgSurfaceMuted,
    required this.bgSurfaceRaised,
    required this.bgBrand,
    required this.bgBrandPressed,
    required this.bgBrandSubtle,
    required this.bgHeroSafe,
    required this.bgHeroWarning,
    required this.bgHeroDanger,
    required this.bgHeroOverlay,
    required this.bgWarningSubtle,
    required this.bgDangerSubtle,
    required this.bgInfoSubtle,
    required this.bgScrim,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnBrand,
    required this.textOnHero,
    required this.textOnHeroMuted,
    required this.textBrand,
    required this.textIncome,
    required this.textWarning,
    required this.textDanger,
    required this.textInfo,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderFocus,
    required this.iconPrimary,
    required this.iconSecondary,
    required this.iconOnBrand,
    required this.iconOnHero,
    required this.statusSafe,
    required this.statusWarning,
    required this.statusDanger,
    required this.tones,
  });

  final Color bgCanvas;
  final Color bgSurface;
  final Color bgSurfaceMuted;
  final Color bgSurfaceRaised;
  final Color bgBrand;
  final Color bgBrandPressed;
  final Color bgBrandSubtle;
  final Color bgHeroSafe;
  final Color bgHeroWarning;
  final Color bgHeroDanger;
  final Color bgHeroOverlay;
  final Color bgWarningSubtle;
  final Color bgDangerSubtle;
  final Color bgInfoSubtle;
  final Color bgScrim;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnBrand;
  final Color textOnHero;
  final Color textOnHeroMuted;
  final Color textBrand;
  final Color textIncome;
  final Color textWarning;
  final Color textDanger;
  final Color textInfo;
  final Color borderDefault;
  final Color borderStrong;
  final Color borderFocus;
  final Color iconPrimary;
  final Color iconSecondary;
  final Color iconOnBrand;
  final Color iconOnHero;
  final Color statusSafe;
  final Color statusWarning;
  final Color statusDanger;

  /// `tone/{brand,amber,blue,violet,red,neutral}/{bg,fg}`.
  final Map<Tone, ToneColors> tones;

  ToneColors tone(Tone tone) => tones[tone]!;

  /// Warna latar kartu Safe-to-Spend sesuai hasil engine risiko.
  Color heroFor(RiskLevel risk) => switch (risk) {
    RiskLevel.safe => bgHeroSafe,
    RiskLevel.warning => bgHeroWarning,
    RiskLevel.danger => bgHeroDanger,
  };

  static const light = AppColors(
    bgCanvas: Palette.neutral50,
    bgSurface: Palette.neutral0,
    bgSurfaceMuted: Palette.neutral100,
    bgSurfaceRaised: Palette.neutral0,
    bgBrand: Palette.brand600,
    bgBrandPressed: Palette.brand700,
    bgBrandSubtle: Palette.brand50,
    bgHeroSafe: Palette.brand800,
    bgHeroWarning: Palette.amber800,
    bgHeroDanger: Palette.red700,
    bgHeroOverlay: Palette.white16,
    bgWarningSubtle: Palette.amber50,
    bgDangerSubtle: Palette.red50,
    bgInfoSubtle: Palette.blue50,
    bgScrim: Palette.scrim,
    textPrimary: Palette.neutral900,
    textSecondary: Palette.neutral600,
    textTertiary: Palette.neutral500,
    textOnBrand: Palette.neutral0,
    textOnHero: Palette.neutral0,
    textOnHeroMuted: Palette.white72,
    textBrand: Palette.brand700,
    textIncome: Palette.brand700,
    textWarning: Palette.amber700,
    textDanger: Palette.red600,
    textInfo: Palette.blue600,
    borderDefault: Palette.neutral200,
    borderStrong: Palette.borderStrongLight,
    borderFocus: Palette.brand600,
    iconPrimary: Palette.neutral800,
    iconSecondary: Palette.neutral500,
    iconOnBrand: Palette.neutral0,
    iconOnHero: Palette.neutral0,
    statusSafe: Palette.brand500,
    statusWarning: Palette.amber500,
    statusDanger: Palette.red500,
    tones: {
      Tone.brand: ToneColors(bg: Palette.brand100, fg: Palette.brand700),
      Tone.amber: ToneColors(bg: Palette.amber100, fg: Palette.amber800),
      Tone.blue: ToneColors(bg: Palette.blue100, fg: Palette.blue600),
      Tone.violet: ToneColors(bg: Palette.violet100, fg: Palette.violet600),
      Tone.red: ToneColors(bg: Palette.red100, fg: Palette.red700),
      Tone.neutral: ToneColors(bg: Palette.neutral100, fg: Palette.neutral600),
    },
  );

  static const dark = AppColors(
    bgCanvas: Palette.neutral950,
    bgSurface: Palette.neutral900,
    bgSurfaceMuted: Palette.neutral800,
    bgSurfaceRaised: Palette.neutral800,
    bgBrand: Palette.brand400,
    bgBrandPressed: Palette.brand300,
    bgBrandSubtle: Palette.brand950,
    bgHeroSafe: Palette.brand900,
    bgHeroWarning: Palette.amber900,
    bgHeroDanger: Palette.red900,
    bgHeroOverlay: Palette.white16,
    bgWarningSubtle: Palette.amber900,
    bgDangerSubtle: Palette.red900,
    bgInfoSubtle: Palette.blue900,
    bgScrim: Palette.scrim,
    textPrimary: Palette.neutral50,
    textSecondary: Palette.neutral300,
    textTertiary: Palette.neutral400,
    textOnBrand: Palette.neutral950,
    textOnHero: Palette.neutral0,
    textOnHeroMuted: Palette.white72,
    textBrand: Palette.brand300,
    textIncome: Palette.brand400,
    textWarning: Palette.amber400,
    textDanger: Palette.red400,
    textInfo: Palette.blue400,
    borderDefault: Palette.neutral800,
    borderStrong: Palette.borderStrongDark,
    borderFocus: Palette.brand400,
    iconPrimary: Palette.neutral100,
    iconSecondary: Palette.neutral400,
    iconOnBrand: Palette.neutral950,
    iconOnHero: Palette.neutral0,
    statusSafe: Palette.brand400,
    statusWarning: Palette.amber400,
    statusDanger: Palette.red400,
    tones: {
      Tone.brand: ToneColors(bg: Palette.brand950, fg: Palette.brand300),
      Tone.amber: ToneColors(bg: Palette.amber900, fg: Palette.amber400),
      Tone.blue: ToneColors(bg: Palette.blue900, fg: Palette.blue400),
      Tone.violet: ToneColors(bg: Palette.violet900, fg: Palette.violet400),
      Tone.red: ToneColors(bg: Palette.red900, fg: Palette.red400),
      Tone.neutral: ToneColors(bg: Palette.neutral800, fg: Palette.neutral300),
    },
  );

  @override
  AppColors copyWith({
    Color? bgCanvas,
    Color? bgSurface,
    Color? bgSurfaceMuted,
    Color? bgSurfaceRaised,
    Color? bgBrand,
    Color? bgBrandPressed,
    Color? bgBrandSubtle,
    Color? bgHeroSafe,
    Color? bgHeroWarning,
    Color? bgHeroDanger,
    Color? bgHeroOverlay,
    Color? bgWarningSubtle,
    Color? bgDangerSubtle,
    Color? bgInfoSubtle,
    Color? bgScrim,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textOnBrand,
    Color? textOnHero,
    Color? textOnHeroMuted,
    Color? textBrand,
    Color? textIncome,
    Color? textWarning,
    Color? textDanger,
    Color? textInfo,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderFocus,
    Color? iconPrimary,
    Color? iconSecondary,
    Color? iconOnBrand,
    Color? iconOnHero,
    Color? statusSafe,
    Color? statusWarning,
    Color? statusDanger,
    Map<Tone, ToneColors>? tones,
  }) {
    return AppColors(
      bgCanvas: bgCanvas ?? this.bgCanvas,
      bgSurface: bgSurface ?? this.bgSurface,
      bgSurfaceMuted: bgSurfaceMuted ?? this.bgSurfaceMuted,
      bgSurfaceRaised: bgSurfaceRaised ?? this.bgSurfaceRaised,
      bgBrand: bgBrand ?? this.bgBrand,
      bgBrandPressed: bgBrandPressed ?? this.bgBrandPressed,
      bgBrandSubtle: bgBrandSubtle ?? this.bgBrandSubtle,
      bgHeroSafe: bgHeroSafe ?? this.bgHeroSafe,
      bgHeroWarning: bgHeroWarning ?? this.bgHeroWarning,
      bgHeroDanger: bgHeroDanger ?? this.bgHeroDanger,
      bgHeroOverlay: bgHeroOverlay ?? this.bgHeroOverlay,
      bgWarningSubtle: bgWarningSubtle ?? this.bgWarningSubtle,
      bgDangerSubtle: bgDangerSubtle ?? this.bgDangerSubtle,
      bgInfoSubtle: bgInfoSubtle ?? this.bgInfoSubtle,
      bgScrim: bgScrim ?? this.bgScrim,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textOnBrand: textOnBrand ?? this.textOnBrand,
      textOnHero: textOnHero ?? this.textOnHero,
      textOnHeroMuted: textOnHeroMuted ?? this.textOnHeroMuted,
      textBrand: textBrand ?? this.textBrand,
      textIncome: textIncome ?? this.textIncome,
      textWarning: textWarning ?? this.textWarning,
      textDanger: textDanger ?? this.textDanger,
      textInfo: textInfo ?? this.textInfo,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderFocus: borderFocus ?? this.borderFocus,
      iconPrimary: iconPrimary ?? this.iconPrimary,
      iconSecondary: iconSecondary ?? this.iconSecondary,
      iconOnBrand: iconOnBrand ?? this.iconOnBrand,
      iconOnHero: iconOnHero ?? this.iconOnHero,
      statusSafe: statusSafe ?? this.statusSafe,
      statusWarning: statusWarning ?? this.statusWarning,
      statusDanger: statusDanger ?? this.statusDanger,
      tones: tones ?? this.tones,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      bgCanvas: l(bgCanvas, other.bgCanvas),
      bgSurface: l(bgSurface, other.bgSurface),
      bgSurfaceMuted: l(bgSurfaceMuted, other.bgSurfaceMuted),
      bgSurfaceRaised: l(bgSurfaceRaised, other.bgSurfaceRaised),
      bgBrand: l(bgBrand, other.bgBrand),
      bgBrandPressed: l(bgBrandPressed, other.bgBrandPressed),
      bgBrandSubtle: l(bgBrandSubtle, other.bgBrandSubtle),
      bgHeroSafe: l(bgHeroSafe, other.bgHeroSafe),
      bgHeroWarning: l(bgHeroWarning, other.bgHeroWarning),
      bgHeroDanger: l(bgHeroDanger, other.bgHeroDanger),
      bgHeroOverlay: l(bgHeroOverlay, other.bgHeroOverlay),
      bgWarningSubtle: l(bgWarningSubtle, other.bgWarningSubtle),
      bgDangerSubtle: l(bgDangerSubtle, other.bgDangerSubtle),
      bgInfoSubtle: l(bgInfoSubtle, other.bgInfoSubtle),
      bgScrim: l(bgScrim, other.bgScrim),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textTertiary: l(textTertiary, other.textTertiary),
      textOnBrand: l(textOnBrand, other.textOnBrand),
      textOnHero: l(textOnHero, other.textOnHero),
      textOnHeroMuted: l(textOnHeroMuted, other.textOnHeroMuted),
      textBrand: l(textBrand, other.textBrand),
      textIncome: l(textIncome, other.textIncome),
      textWarning: l(textWarning, other.textWarning),
      textDanger: l(textDanger, other.textDanger),
      textInfo: l(textInfo, other.textInfo),
      borderDefault: l(borderDefault, other.borderDefault),
      borderStrong: l(borderStrong, other.borderStrong),
      borderFocus: l(borderFocus, other.borderFocus),
      iconPrimary: l(iconPrimary, other.iconPrimary),
      iconSecondary: l(iconSecondary, other.iconSecondary),
      iconOnBrand: l(iconOnBrand, other.iconOnBrand),
      iconOnHero: l(iconOnHero, other.iconOnHero),
      statusSafe: l(statusSafe, other.statusSafe),
      statusWarning: l(statusWarning, other.statusWarning),
      statusDanger: l(statusDanger, other.statusDanger),
      tones: {for (final key in Tone.values) key: ToneColors.lerp(tone(key), other.tone(key), t)},
    );
  }
}
