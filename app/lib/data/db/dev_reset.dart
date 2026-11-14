import 'package:drift/drift.dart';

import 'app_database.dart';

/// Menghapus semua data pengguna kecuali kategori, supaya onboarding bisa
/// diulang saat pengembangan. Hanya dipanggil dari menu debug di Beranda.
Future<void> resetUserData(AppDatabase db) => db.transaction(() async {
  // Urutan mengikuti foreign key: anak dulu, induk belakangan.
  for (final table in <TableInfo<Table, Object?>>[
    db.goalContributions,
    db.transactions,
    db.obligationInstances,
    db.obligations,
    db.savingsGoals,
    db.alerts,
    db.alertThresholds,
    db.accounts,
    db.payCycleConfigs,
  ]) {
    await db.delete(table).go();
  }
});
