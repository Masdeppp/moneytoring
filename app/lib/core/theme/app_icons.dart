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

  // Aksi & navigasi lokal
  static const IconData chevronLeft = LucideIcons.chevronLeft;
  static const IconData close = LucideIcons.x;
  static const IconData sparkles = LucideIcons.sparkles;
  static const IconData rotateCcw = LucideIcons.rotateCcw;
  static const IconData calendar = LucideIcons.calendar;
  static const IconData pencil = LucideIcons.pencil;
  static const IconData backspace = LucideIcons.delete;
  static const IconData check = LucideIcons.check;
  static const IconData search = LucideIcons.search;
  static const IconData chevronDown = LucideIcons.chevronDown;
  static const IconData chevronRight = LucideIcons.chevronRight;
  static const IconData settings = LucideIcons.settings;
  static const IconData trash = LucideIcons.trash2;
  static const IconData archive = LucideIcons.archive;
  static const IconData target = LucideIcons.target;
  static const IconData tag = LucideIcons.tag;

  // Arus kas (ringkasan siklus layar 07)
  static const IconData arrowDownLeft = LucideIcons.arrowDownLeft;
  static const IconData arrowUpRight = LucideIcons.arrowUpRight;

  // Kategori bawaan
  static const IconData utensils = LucideIcons.utensils;
  static const IconData bus = LucideIcons.bus;
  static const IconData shoppingBag = LucideIcons.shoppingBag;
  static const IconData receipt = LucideIcons.receipt;

  // Developer
  static const IconData hammer = LucideIcons.hammer;
  static const IconData palette = LucideIcons.palette;
  static const IconData database = LucideIcons.database;

  /// Ikon kategori dan akun disimpan di database sebagai nama Lucide
  /// (kolom `icon`), mis. `credit-card`. Nama yang tidak dikenal memakai
  /// lingkaran supaya tampilan tidak rusak.
  static IconData named(String name) => _byName[name] ?? LucideIcons.circle;

  static const Map<String, IconData> _byName = {
    // Kategori bawaan (lihat `defaultCategories`)
    'utensils': LucideIcons.utensils,
    'bus': LucideIcons.bus,
    'shopping-bag': LucideIcons.shoppingBag,
    'house': LucideIcons.house,
    'receipt': LucideIcons.receipt,
    'credit-card': LucideIcons.creditCard,
    'heart-pulse': LucideIcons.heartPulse,
    'graduation-cap': LucideIcons.graduationCap,
    'clapperboard': LucideIcons.clapperboard,
    'ellipsis': LucideIcons.ellipsis,
    'wallet': LucideIcons.wallet,
    'gift': LucideIcons.gift,
    'plus': LucideIcons.plus,
    // Akun (lihat `AccountTypeDefaults`)
    'banknote': LucideIcons.banknote,
    'landmark': LucideIcons.landmark,
    'piggy-bank': LucideIcons.piggyBank,
    // Pilihan tambahan untuk kategori custom (lihat [categoryIconNames])
    'coffee': LucideIcons.coffee,
    'shopping-cart': LucideIcons.shoppingCart,
    'car': LucideIcons.car,
    'fuel': LucideIcons.fuel,
    'bike': LucideIcons.bike,
    'train': LucideIcons.train,
    'plane': LucideIcons.plane,
    'zap': LucideIcons.zap,
    'droplet': LucideIcons.droplet,
    'wifi': LucideIcons.wifi,
    'smartphone': LucideIcons.smartphone,
    'pill': LucideIcons.pill,
    'book-open': LucideIcons.bookOpen,
    'gamepad-2': LucideIcons.gamepad2,
    'music': LucideIcons.music,
    'tv': LucideIcons.tv,
    'dumbbell': LucideIcons.dumbbell,
    'shirt': LucideIcons.shirt,
    'scissors': LucideIcons.scissors,
    'baby': LucideIcons.baby,
    'paw-print': LucideIcons.pawPrint,
    'users': LucideIcons.users,
    'hand-heart': LucideIcons.handHeart,
    'wrench': LucideIcons.wrench,
    'laptop': LucideIcons.laptop,
    'store': LucideIcons.store,
    'briefcase': LucideIcons.briefcase,
    'coins': LucideIcons.coins,
    'hand-coins': LucideIcons.handCoins,
    'trending-up': LucideIcons.trendingUp,
    'target': LucideIcons.target,
  };

  /// Ikon yang ditawarkan saat membuat atau mengubah kategori
  /// (Pengaturan → Kategori). Semua nama di sini harus ada di [_byName].
  static const List<String> categoryIconNames = [
    'utensils',
    'coffee',
    'shopping-cart',
    'shopping-bag',
    'bus',
    'car',
    'fuel',
    'bike',
    'train',
    'plane',
    'house',
    'zap',
    'droplet',
    'wifi',
    'smartphone',
    'receipt',
    'credit-card',
    'heart-pulse',
    'pill',
    'graduation-cap',
    'book-open',
    'clapperboard',
    'gamepad-2',
    'music',
    'tv',
    'dumbbell',
    'shirt',
    'scissors',
    'baby',
    'paw-print',
    'users',
    'hand-heart',
    'gift',
    'wrench',
    'laptop',
    'store',
    'briefcase',
    'wallet',
    'banknote',
    'coins',
    'hand-coins',
    'trending-up',
    'piggy-bank',
    'target',
    'ellipsis',
  ];
}
