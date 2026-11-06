import 'package:flutter/painting.dart';

/// Spacing dari DESIGN.md §3. Padding layar: 16 (utama), 24 (onboarding).
abstract final class AppSpacing {
  static const double s0 = 0;
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;

  static const double screen = s16;
  static const double screenOnboarding = s24;
}

/// Radius dari DESIGN.md §3. Kartu = lg, kartu hero = xl,
/// tombol/chip = full, tile kategori = md.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double full = 999;
}

/// Bayangan dari DESIGN.md §3 (`Elevation/1` dan `Elevation/2`).
abstract final class AppShadows {
  /// Kartu: y1 b2 6% + y4 b12 5%.
  static const elevation1 = <BoxShadow>[
    BoxShadow(color: Color(0x0F0C100F), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x0D0C100F), offset: Offset(0, 4), blurRadius: 12),
  ];

  /// FAB, sheet: y4 b8 10% + y12 b32 spread −4 12%.
  static const elevation2 = <BoxShadow>[
    BoxShadow(color: Color(0x1A0C100F), offset: Offset(0, 4), blurRadius: 8),
    BoxShadow(color: Color(0x1F0C100F), offset: Offset(0, 12), blurRadius: 32, spreadRadius: -4),
  ];
}
