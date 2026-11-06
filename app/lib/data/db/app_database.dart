import 'package:drift/drift.dart';

import '../../core/model/enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Transactions,
    PayCycleConfigs,
    Obligations,
    ObligationInstances,
    SavingsTargets,
    Alerts,
    AlertThresholds,
    Entitlements,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Di aplikasi: `AppDatabase(openEncryptedDatabase())`.
  /// Di test: `AppDatabase(NativeDatabase.memory())`.
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await batch((b) => b.insertAll(categories, defaultCategories));
    },
    // onUpgrade ditambahkan saat schemaVersion pertama kali naik, memakai
    // `stepByStep` dari file hasil `dart run drift_dev make-migrations`.
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

/// Kategori bawaan yang dibuat saat database pertama kali dibuat.
/// Merah sengaja tidak dipakai: merah hanya untuk risiko (DESIGN.md §1.3).
final List<CategoriesCompanion> defaultCategories = [
  for (final (index, c) in _defaultCategorySpecs.indexed)
    CategoriesCompanion.insert(
      name: c.name,
      type: c.type,
      icon: c.icon,
      tone: c.tone,
      isDefault: const Value(true),
      sortOrder: Value(index),
    ),
];

const _defaultCategorySpecs = <({String name, CategoryType type, String icon, Tone tone})>[
  (name: 'Makan & minum', type: CategoryType.expense, icon: 'utensils', tone: Tone.amber),
  (name: 'Transportasi', type: CategoryType.expense, icon: 'bus', tone: Tone.blue),
  (name: 'Belanja', type: CategoryType.expense, icon: 'shopping-bag', tone: Tone.violet),
  (name: 'Tempat tinggal', type: CategoryType.expense, icon: 'house', tone: Tone.brand),
  (name: 'Tagihan & utilitas', type: CategoryType.expense, icon: 'receipt', tone: Tone.neutral),
  (name: 'Cicilan', type: CategoryType.expense, icon: 'credit-card', tone: Tone.violet),
  (name: 'Kesehatan', type: CategoryType.expense, icon: 'heart-pulse', tone: Tone.brand),
  (name: 'Pendidikan', type: CategoryType.expense, icon: 'graduation-cap', tone: Tone.blue),
  (name: 'Hiburan', type: CategoryType.expense, icon: 'clapperboard', tone: Tone.amber),
  (name: 'Lainnya', type: CategoryType.expense, icon: 'ellipsis', tone: Tone.neutral),
  (name: 'Gaji', type: CategoryType.income, icon: 'wallet', tone: Tone.brand),
  (name: 'Bonus', type: CategoryType.income, icon: 'gift', tone: Tone.amber),
  (name: 'Pemasukan lain', type: CategoryType.income, icon: 'plus', tone: Tone.neutral),
];
