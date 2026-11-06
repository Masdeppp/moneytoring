import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Ikon aplikasi (Lucide, stroke 2, sama seperti di Figma).
///
/// Semua widget mengambil ikon dari sini, bukan langsung dari `LucideIcons`,
/// supaya penggantian set ikon cukup di satu file.
abstract final class AppIcons {
  // Navigasi
  static const IconData house = LucideIcons.house;
  static const IconData arrowLeftRight = LucideIcons.arrowLeftRight;
  static const IconData calendarCheck = LucideIcons.calendarCheck;
  static const IconData chartPie = LucideIcons.chartPie;
  static const IconData plus = LucideIcons.plus;
  static const IconData bell = LucideIcons.bell;

  // Status
  static const IconData shieldCheck = LucideIcons.shieldCheck;
  static const IconData triangleAlert = LucideIcons.triangleAlert;
  static const IconData octagonAlert = LucideIcons.octagonAlert;
  static const IconData info = LucideIcons.info;

  // Kategori bawaan
  static const IconData utensils = LucideIcons.utensils;
  static const IconData bus = LucideIcons.bus;
  static const IconData shoppingBag = LucideIcons.shoppingBag;
  static const IconData receipt = LucideIcons.receipt;

  // Developer
  static const IconData hammer = LucideIcons.hammer;
  static const IconData palette = LucideIcons.palette;
  static const IconData database = LucideIcons.database;
}
