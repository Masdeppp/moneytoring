import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// Target tabungan per siklus (opsional, PRD §8.1 onboarding).
class SavingsRepository {
  SavingsRepository(this._db);

  final AppDatabase _db;

  Future<List<SavingsTargetRecord>> targets() => _db.select(_db.savingsTargets).get();

  /// MVP memakai satu target. [amountPerCycle] 0 berarti tanpa target.
  ///
  /// [accountId] adalah rekening tujuan menabung. Transfer ke rekening itu
  /// dihitung sebagai tabungan yang sudah disisihkan; tanpa rekening, target
  /// dicadangkan penuh sepanjang siklus.
  Future<void> setTarget({required int amountPerCycle, int? accountId}) {
    if (amountPerCycle < 0) {
      throw ArgumentError.value(amountPerCycle, 'amountPerCycle', 'tidak boleh negatif');
    }
    return _db.transaction(() async {
      await _db.delete(_db.savingsTargets).go();
      if (amountPerCycle > 0) {
        await _db
            .into(_db.savingsTargets)
            .insert(
              SavingsTargetsCompanion.insert(
                amountPerCycle: amountPerCycle,
                accountId: Value(accountId),
              ),
            );
      }
    });
  }
}
