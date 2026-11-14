import 'package:drift/drift.dart';

import '../../core/model/enums.dart';
import '../../engine/common/local_date.dart';
import '../db/app_database.dart';

/// Target tabungan beserta setorannya, relatif ke satu siklus.
final class SavingsGoalProgress {
  const SavingsGoalProgress({
    required this.goal,
    required this.savedBeforeCycle,
    required this.savedThisCycle,
    required this.keptInSafeToSpend,
    this.accountName,
  });

  final SavingsGoalRecord goal;
  final int savedBeforeCycle;
  final int savedThisCycle;

  /// Uangnya masih di akun yang dihitung Safe-to-Spend: tanpa rekening tujuan,
  /// atau rekening tujuannya ikut dihitung.
  final bool keptInSafeToSpend;

  /// Nama rekening tujuan, kalau ada.
  final String? accountName;

  LocalDate? get deadline => switch (goal.deadline) {
    final date? => LocalDate.fromDateTime(date),
    null => null,
  };

  /// Target sistem "Sisa gaji" (sisihan persen gaji), bukan target buatan pengguna.
  bool get isSalaryShare => goal.salaryBasisPoints != null;
}

/// Isian target tabungan dari editor.
typedef SavingsGoalInput = ({
  String name,
  int? targetAmount,
  LocalDate? deadline,
  int? amountPerCycle,
  int? accountId,
});

/// Target tabungan bernama (PRD v0.3 §7.3) dan setorannya.
class SavingsRepository {
  SavingsRepository(this._db);

  final AppDatabase _db;

  static const _progressSql = '''
    SELECT g.*,
      COALESCE((SELECT SUM(c.amount) FROM goal_contributions c
                WHERE c.goal_id = g.id AND c.date < ?1), 0) AS saved_before,
      COALESCE((SELECT SUM(c.amount) FROM goal_contributions c
                WHERE c.goal_id = g.id AND c.date >= ?1
                  AND (?2 IS NULL OR c.date <= ?2)), 0) AS saved_this_cycle,
      COALESCE(a.include_in_safe_to_spend, 1) AS kept_in_safe_to_spend,
      a.name AS account_name
    FROM savings_goals g
    LEFT JOIN accounts a ON a.id = g.account_id
    WHERE g.archived = 0
    ORDER BY g.id''';

  Selectable<SavingsGoalProgress> _progress(LocalDate cycleStart, {LocalDate? lastDay}) => _db
      .customSelect(
        _progressSql,
        variables: [
          Variable<DateTime>(cycleStart.toUtcMidnight()),
          Variable<DateTime>(lastDay?.toUtcMidnight()),
        ],
        readsFrom: {_db.savingsGoals, _db.goalContributions, _db.accounts},
      )
      .map(
        (row) => SavingsGoalProgress(
          goal: _db.savingsGoals.map(row.data),
          savedBeforeCycle: row.read<int>('saved_before'),
          savedThisCycle: row.read<int>('saved_this_cycle'),
          keptInSafeToSpend: row.read<bool>('kept_in_safe_to_spend'),
          accountName: row.readNullable<String>('account_name'),
        ),
      );

  /// Target aktif dengan setoran sebelum dan sejak [cycleStart].
  Future<List<SavingsGoalProgress>> progress(LocalDate cycleStart) => _progress(cycleStart).get();

  Stream<List<SavingsGoalProgress>> watchProgress(LocalDate cycleStart) =>
      _progress(cycleStart).watch();

  /// Seperti [progress], tetapi setoran setelah [lastDay] (hari terakhir
  /// siklus) tidak dihitung: keadaan target saat siklus itu berakhir.
  Future<List<SavingsGoalProgress>> progressThrough(LocalDate cycleStart, LocalDate lastDay) =>
      _progress(cycleStart, lastDay: lastDay).get();

  /// Nama target sistem untuk sisihan persen gaji.
  static const salaryGoalName = 'Sisa gaji';

  /// Target "Sisa gaji" yang aktif, kalau ada.
  Future<SavingsGoalRecord?> salaryGoal() =>
      (_db.select(_db.savingsGoals)
            ..where((g) => g.salaryBasisPoints.isNotNull() & g.archived.not())
            ..limit(1))
          .getSingleOrNull();

  /// Mengatur persen gaji yang disisihkan tiap siklus.
  ///
  /// Target "Sisa gaji" dibuat saat persen pertama kali diisi; sisihan siklus
  /// setelah [settledThrough] yang ditabung otomatis. Persen 0 menghentikan
  /// sisihan baru; targetnya ikut dihapus kalau belum ada tabungannya.
  Future<void> setSalaryShare(int basisPoints, {required LocalDate settledThrough}) {
    RangeError.checkValueInInterval(basisPoints, 0, 10000, 'basisPoints');
    return _db.transaction(() async {
      final goal = await salaryGoal();
      if (goal == null) {
        if (basisPoints == 0) return;
        await _db
            .into(_db.savingsGoals)
            .insert(
              SavingsGoalsCompanion.insert(
                name: salaryGoalName,
                icon: const Value('coins'),
                salaryBasisPoints: Value(basisPoints),
                settledThrough: Value(settledThrough.toUtcMidnight()),
              ),
            );
        return;
      }
      if (basisPoints == 0 && !await hasContributions(goal.id)) {
        await delete(goal.id);
        return;
      }
      await (_db.update(_db.savingsGoals)..where((g) => g.id.equals(goal.id))).write(
        SavingsGoalsCompanion(salaryBasisPoints: Value(basisPoints)),
      );
    });
  }

  /// Menabung sisihan gaji siklus yang berakhir di [lastDay] sebesar [amount]
  /// (boleh 0), lalu menandai siklus itu sudah ditabung.
  ///
  /// Siklus yang sudah ditabung dilewati, jadi aman dipanggil dua kali.
  Future<void> recordSalaryLeftover(
    int goalId, {
    required LocalDate lastDay,
    required int amount,
  }) => _db.transaction(() async {
    final goal = await (_db.select(
      _db.savingsGoals,
    )..where((g) => g.id.equals(goalId))).getSingle();
    final settled = goal.settledThrough;
    if (settled != null && LocalDate.fromDateTime(settled) >= lastDay) return;
    if (amount > 0) {
      await _db
          .into(_db.goalContributions)
          .insert(
            GoalContributionsCompanion.insert(
              goalId: goalId,
              amount: amount,
              date: lastDay.toUtcMidnight(),
            ),
          );
    }
    await (_db.update(_db.savingsGoals)..where((g) => g.id.equals(goalId))).write(
      SavingsGoalsCompanion(settledThrough: Value(lastDay.toUtcMidnight())),
    );
  });

  Future<bool> hasContributions(int goalId) async =>
      await (_db.select(_db.goalContributions)
            ..where((c) => c.goalId.equals(goalId))
            ..limit(1))
          .getSingleOrNull() !=
      null;

  /// Menghapus semua setoran target (tanpa transfer yang terhubung).
  Future<void> deleteContributions(int goalId) =>
      (_db.delete(_db.goalContributions)..where((c) => c.goalId.equals(goalId))).go();

  Future<int> create(SavingsGoalInput input) =>
      _db.into(_db.savingsGoals).insert(_companion(input));

  Future<void> update(int id, SavingsGoalInput input) =>
      (_db.update(_db.savingsGoals)..where((g) => g.id.equals(id))).write(_companion(input));

  /// Target selesai (dananya dipakai) atau dihentikan: tidak lagi dicadangkan,
  /// riwayat setorannya tetap ada.
  Future<void> archive(int id) => (_db.update(
    _db.savingsGoals,
  )..where((g) => g.id.equals(id))).write(const SavingsGoalsCompanion(archived: Value(true)));

  /// Menghapus target dan catatan setorannya. Transfer ke rekening tujuan
  /// tetap ada sebagai transfer biasa.
  Future<void> delete(int id) => (_db.delete(_db.savingsGoals)..where((g) => g.id.equals(id))).go();

  /// Mencatat setoran. Kalau target punya rekening tujuan dan [fromAccountId]
  /// diisi, uangnya dipindah lewat transaksi transfer; setorannya ikut
  /// terhapus kalau transfer itu dihapus.
  Future<int> contribute({
    required int goalId,
    required int amount,
    required DateTime date,
    int? fromAccountId,
  }) {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount', 'harus lebih dari 0');
    return _db.transaction(() async {
      final goal = await (_db.select(
        _db.savingsGoals,
      )..where((g) => g.id.equals(goalId))).getSingle();
      final toAccountId = goal.accountId;
      int? transactionId;
      if (toAccountId != null && fromAccountId != null && fromAccountId != toAccountId) {
        transactionId = await _db
            .into(_db.transactions)
            .insert(
              TransactionsCompanion.insert(
                type: TransactionType.transfer,
                amount: amount,
                accountId: fromAccountId,
                toAccountId: Value(toAccountId),
                date: date,
                note: Value('Tabungan ${goal.name}'),
              ),
            );
      }
      return _db
          .into(_db.goalContributions)
          .insert(
            GoalContributionsCompanion.insert(
              goalId: goalId,
              amount: amount,
              date: LocalDate.fromDateTime(date).toUtcMidnight(),
              transactionId: Value(transactionId),
            ),
          );
    });
  }

  /// Riwayat setoran, terbaru dulu.
  Stream<List<GoalContributionRecord>> watchContributions(int goalId) =>
      (_db.select(_db.goalContributions)
            ..where((c) => c.goalId.equals(goalId))
            ..orderBy([(c) => OrderingTerm.desc(c.date), (c) => OrderingTerm.desc(c.id)]))
          .watch();

  /// Membatalkan setoran, termasuk transfernya kalau ada.
  Future<void> deleteContribution(int id) => _db.transaction(() async {
    final contribution = await (_db.select(
      _db.goalContributions,
    )..where((c) => c.id.equals(id))).getSingle();
    final transactionId = contribution.transactionId;
    if (transactionId != null) {
      // Setoran ikut terhapus lewat ON DELETE CASCADE.
      await (_db.delete(_db.transactions)..where((t) => t.id.equals(transactionId))).go();
    } else {
      await (_db.delete(_db.goalContributions)..where((c) => c.id.equals(id))).go();
    }
  });

  static SavingsGoalsCompanion _companion(SavingsGoalInput input) {
    final name = input.name.trim();
    if (name.isEmpty) throw ArgumentError.value(input.name, 'name', 'tidak boleh kosong');
    final target = input.targetAmount;
    final perCycle = input.amountPerCycle;
    if (target != null && target <= 0) {
      throw ArgumentError.value(target, 'targetAmount', 'harus lebih dari 0');
    }
    if (perCycle != null && perCycle <= 0) {
      throw ArgumentError.value(perCycle, 'amountPerCycle', 'harus lebih dari 0');
    }
    if (input.deadline != null && target == null) {
      throw ArgumentError('Tenggat butuh nominal target');
    }
    if (input.deadline == null && perCycle == null) {
      throw ArgumentError('Isi tenggat atau setoran per siklus');
    }
    return SavingsGoalsCompanion(
      name: Value(name),
      targetAmount: Value(target),
      deadline: Value(input.deadline?.toUtcMidnight()),
      amountPerCycle: Value(input.deadline == null ? perCycle : null),
      accountId: Value(input.accountId),
    );
  }
}
