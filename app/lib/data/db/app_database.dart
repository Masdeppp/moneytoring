import 'package:drift/drift.dart';

import '../../core/model/enums.dart';
import 'app_database.steps.dart';
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
    SavingsGoals,
    GoalContributions,
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
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await batch((b) => b.insertAll(categories, defaultCategories));
    },
    onUpgrade: (m, from, to) async {
      // Membuat ulang tabel saat foreign key aktif akan menghapus baris anak
      // lewat ON DELETE CASCADE. Matikan dulu (harus di luar transaksi),
      // lalu cek ulang sebelum commit supaya migrasi yang merusak relasi
      // dibatalkan seluruhnya.
      await customStatement('PRAGMA foreign_keys = OFF');
      await transaction(() async {
        await _migrationSteps(m, from, to);
        final violations = await customSelect('PRAGMA foreign_key_check').get();
        if (violations.isNotEmpty) {
          throw StateError(
            'Migrasi v$from → v$to merusak foreign key: '
            '${violations.map((row) => row.data).toList()}',
          );
        }
      });
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

/// Langkah migrasi per versi. File `app_database.steps.dart` dibuat ulang oleh
/// `dart run drift_dev make-migrations` setiap kali `schemaVersion` naik.
final OnUpgrade _migrationSteps = stepByStep(
  from1To2: (m, schema) async {
    final migratedAt = Variable<DateTime>(DateTime.now());

    await m.addColumn(schema.accounts, schema.accounts.includeInSafeToSpend);

    // Kolom tanggal wajib tanpa default tidak bisa ditambah lewat ALTER TABLE,
    // jadi tabelnya dibuat ulang dan baris lama diisi tanggal migrasi.
    await m.alterTable(
      TableMigration(
        schema.payCycleConfigs,
        newColumns: [
          schema.payCycleConfigs.trackingSince,
          schema.payCycleConfigs.bufferBasisPoints,
        ],
        columnTransformer: {schema.payCycleConfigs.trackingSince: migratedAt},
      ),
    );
    await m.alterTable(
      TableMigration(
        schema.obligations,
        newColumns: [schema.obligations.startsOn],
        columnTransformer: {schema.obligations.startsOn: migratedAt},
      ),
    );

    // Kolom cycle_start dibuang dan kunci unik pindah ke (obligation_id, due_date).
    await m.alterTable(TableMigration(schema.obligationInstances));

    await m.create(schema.idxObligationInstancesDue);
    await m.create(schema.idxTransactionsObligationInstance);
  },
  from2To3: (m, schema) async {
    // Target tunggal per siklus menjadi target bernama tanpa tenggat dengan
    // nominal per siklus yang sama (docs/FASE1.md, "Target tabungan bernama").
    await m.create(schema.savingsGoals);
    await m.create(schema.goalContributions);
    await m.create(schema.idxGoalContributionsGoal);
    await m.database.customStatement('''
      INSERT INTO savings_goals (name, amount_per_cycle, account_id)
      SELECT 'Tabungan', amount_per_cycle, account_id
      FROM savings_targets WHERE amount_per_cycle > 0''');
    await m.deleteTable('savings_targets');
  },
  from3To4: (m, schema) async {
    // Sisihan persen gaji yang ditabung otomatis saat gajian (docs/FASE1.md,
    // "Sisihkan dari gaji"). Target lama tetap target biasa (kolom kosong).
    await m.addColumn(schema.savingsGoals, schema.savingsGoals.salaryBasisPoints);
    await m.addColumn(schema.savingsGoals, schema.savingsGoals.settledThrough);
  },
);

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
