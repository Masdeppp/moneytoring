import 'package:drift/drift.dart';

import '../../core/model/enums.dart';
import '../../engine/common/local_date.dart';
import '../../engine/cycle/obligation_schedule.dart';
import '../../engine/cycle/pay_cycle.dart';
import '../../engine/safe_to_spend/safe_to_spend.dart';
import '../db/app_database.dart';

/// Satu jatuh tempo kewajiban beserta pembayaran yang sudah tercatat.
final class ObligationDueView {
  const ObligationDueView({
    required this.instance,
    required this.obligationName,
    required this.categoryId,
    required this.accountId,
    required this.amountType,
    required this.paidAmount,
    this.lastPaidAt,
    this.lastPaidAccountName,
  });

  final ObligationInstanceRecord instance;
  final String obligationName;
  final int categoryId;
  final int? accountId;
  final ObligationAmountType amountType;

  /// Total transaksi pengeluaran yang terhubung ke jatuh tempo ini.
  final int paidAmount;

  /// Waktu dan akun pembayaran terakhir ("Dibayar 3 Nov · BCA").
  final DateTime? lastPaidAt;
  final String? lastPaidAccountName;

  int get obligationId => instance.obligationId;

  int get instanceId => instance.id;
  LocalDate get dueDate => LocalDate.fromDateTime(instance.dueDate);
  ObligationStatus get status => instance.status;

  ObligationDue toEngine() => ObligationDue(
    dueDate: dueDate,
    expectedAmount: instance.expectedAmount,
    paidAmount: paidAmount,
    status: instance.status,
  );

  /// Uang yang masih harus disiapkan.
  int get remaining => toEngine().remaining;
}

/// Kewajiban rutin dan jatuh temponya (PRD §7.2).
class ObligationRepository {
  ObligationRepository(this._db);

  final AppDatabase _db;

  static final _beginningOfTime = LocalDate(1970, 1, 1);

  Future<int> create({
    required String name,
    required ObligationAmountType amountType,
    required int amount,
    required int dueDay,
    required int categoryId,
    required LocalDate startsOn,
    int? accountId,
    String autoMatchKeywords = '',
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(name, 'name', 'tidak boleh kosong');
    if (amount <= 0) throw ArgumentError.value(amount, 'amount', 'harus lebih dari 0');
    RangeError.checkValueInInterval(dueDay, 1, 31, 'dueDay');
    return _db
        .into(_db.obligations)
        .insert(
          ObligationsCompanion.insert(
            name: trimmed,
            amountType: amountType,
            amount: amount,
            dueDay: dueDay,
            categoryId: categoryId,
            accountId: Value(accountId),
            autoMatchKeywords: Value(autoMatchKeywords),
            startsOn: startsOn.toUtcMidnight(),
          ),
        );
  }

  /// Mengubah kewajiban (layar 08). Jatuh tempo yang belum lunas ikut
  /// menyesuaikan:
  /// - nominal baru dipakai untuk semua jatuh tempo yang belum lunas;
  /// - kalau tanggalnya berubah, jatuh tempo mulai hari ini yang belum ada
  ///   pembayarannya dihapus. Tanggal baru berlaku mulai bulan setelah jatuh
  ///   tempo terakhir yang tersisa (dan tidak sebelum [today]), supaya satu
  ///   bulan tidak tertagih dua kali. Jatuh temponya dibuat lagi oleh
  ///   [ensureInstances].
  Future<void> update(
    int id, {
    required String name,
    required ObligationAmountType amountType,
    required int amount,
    required int dueDay,
    required int categoryId,
    required LocalDate today,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(name, 'name', 'tidak boleh kosong');
    if (amount <= 0) throw ArgumentError.value(amount, 'amount', 'harus lebih dari 0');
    RangeError.checkValueInInterval(dueDay, 1, 31, 'dueDay');
    return _db.transaction(() async {
      final current = await (_db.select(
        _db.obligations,
      )..where((o) => o.id.equals(id))).getSingle();
      final dayChanged = current.dueDay != dueDay;

      final open =
          await (_db.select(_db.obligationInstances)..where(
                (i) =>
                    i.obligationId.equals(id) &
                    i.status.isInValues([ObligationStatus.pending, ObligationStatus.late]),
              ))
              .get();
      for (final instance in open) {
        final due = LocalDate.fromDateTime(instance.dueDate);
        if (dayChanged && due >= today && await _paidFor(instance.id) == 0) {
          await (_db.delete(_db.obligationInstances)..where((i) => i.id.equals(instance.id))).go();
        } else if (instance.expectedAmount != amount) {
          await (_db.update(_db.obligationInstances)..where((i) => i.id.equals(instance.id))).write(
            ObligationInstancesCompanion(expectedAmount: Value(amount)),
          );
          await refreshObligationStatus(_db, instance.id);
        }
      }

      var startsOn = LocalDate.fromDateTime(current.startsOn);
      if (dayChanged) {
        final latest = _db.obligationInstances.dueDate.max();
        final row =
            await (_db.selectOnly(_db.obligationInstances)
                  ..addColumns([latest])
                  ..where(_db.obligationInstances.obligationId.equals(id)))
                .getSingle();
        final last = row.read(latest);
        final nextMonth = last == null
            ? today
            : LocalDate(last.toUtc().year, last.toUtc().month + 1, 1);
        startsOn = nextMonth > today ? nextMonth : today;
      }

      await (_db.update(_db.obligations)..where((o) => o.id.equals(id))).write(
        ObligationsCompanion(
          name: Value(trimmed),
          amountType: Value(amountType),
          amount: Value(amount),
          dueDay: Value(dueDay),
          categoryId: Value(categoryId),
          startsOn: Value(startsOn.toUtcMidnight()),
        ),
      );
    });
  }

  Future<int> _paidFor(int instanceId) async {
    final t = _db.transactions;
    final total = t.amount.sum();
    final row =
        await (_db.selectOnly(t)
              ..addColumns([total])
              ..where(t.obligationInstanceId.equals(instanceId)))
            .getSingle();
    return row.read(total) ?? 0;
  }

  SimpleSelectStatement<$ObligationsTable, ObligationRecord> _active() =>
      _db.select(_db.obligations)
        ..where((o) => o.active.equals(true))
        ..orderBy([
          (o) => OrderingTerm(expression: o.dueDay),
          (o) => OrderingTerm(expression: o.id),
        ]);

  Future<List<ObligationRecord>> active() => _active().get();

  Stream<List<ObligationRecord>> watchActive() => _active().watch();

  /// Kewajiban nonaktif tidak dibuatkan jatuh tempo baru dan tidak dicadangkan.
  Future<void> setActive(int id, {required bool active}) => (_db.update(
    _db.obligations,
  )..where((o) => o.id.equals(id))).write(ObligationsCompanion(active: Value(active)));

  /// Menghapus kewajiban beserta jatuh temponya. Transaksi pembayarannya tetap
  /// ada, hanya tidak lagi terhubung.
  Future<void> delete(int id) => (_db.delete(_db.obligations)..where((o) => o.id.equals(id))).go();

  /// Membuat jatuh tempo yang belum ada untuk siklus berjalan dan siklus
  /// sebelumnya (kalau aplikasi lama tidak dibuka). Mengembalikan jumlah
  /// instance baru; tidak menulis apa pun kalau semuanya sudah ada, supaya
  /// aman dipanggil dari stream yang memantau tabel ini.
  Future<int> ensureInstances({
    required PayCycleCalculator calculator,
    required LocalDate today,
  }) async {
    final cycle = calculator.cycleContaining(today);
    final windowStart = calculator.previousCycle(cycle).start.addDays(1);
    final obligations = await active();
    if (obligations.isEmpty) return 0;

    final existing =
        await (_db.select(_db.obligationInstances)..where(
              (i) =>
                  i.obligationId.isIn(obligations.map((o) => o.id)) &
                  i.dueDate.isBiggerOrEqualValue(windowStart.toUtcMidnight()),
            ))
            .get();
    final have = {
      for (final instance in existing)
        (instance.obligationId, LocalDate.fromDateTime(instance.dueDate)),
    };

    final missing = <ObligationInstancesCompanion>[
      for (final obligation in obligations)
        for (final due in monthlyDueDatesBetween(
          obligation.dueDay,
          _later(windowStart, LocalDate.fromDateTime(obligation.startsOn)),
          cycle.nextPayday,
        ))
          if (!have.contains((obligation.id, due)))
            ObligationInstancesCompanion.insert(
              obligationId: obligation.id,
              dueDate: due.toUtcMidnight(),
              expectedAmount: obligation.amount,
            ),
    ];
    if (missing.isNotEmpty) {
      await _db.batch(
        (b) => b.insertAll(_db.obligationInstances, missing, mode: InsertMode.insertOrIgnore),
      );
    }
    return missing.length;
  }

  static const _duesSql = '''
    SELECT i.*,
      o.name AS obligation_name,
      o.category_id AS obligation_category_id,
      o.account_id AS obligation_account_id,
      o.amount_type AS obligation_amount_type,
      COALESCE((SELECT SUM(t.amount) FROM transactions t
                WHERE t.obligation_instance_id = i.id AND t.type = 'expense'), 0) AS paid_amount,
      (SELECT t.date FROM transactions t
        WHERE t.obligation_instance_id = i.id AND t.type = 'expense'
        ORDER BY unixepoch(t.date) DESC, t.id DESC LIMIT 1) AS last_paid_date,
      (SELECT a.name FROM transactions t JOIN accounts a ON a.id = t.account_id
        WHERE t.obligation_instance_id = i.id AND t.type = 'expense'
        ORDER BY unixepoch(t.date) DESC, t.id DESC LIMIT 1) AS last_paid_account
    FROM obligation_instances i
    JOIN obligations o ON o.id = i.obligation_id
    WHERE o.active = 1
      AND ((i.due_date >= ?1 AND i.due_date <= ?2)
        OR (?4 = 1 AND i.due_date < ?1 AND i.status IN ('pending', 'late')))
      AND (?3 = 0 OR i.status IN ('pending', 'late'))
    ORDER BY i.due_date, o.name''';

  Selectable<ObligationDueView> _dues({
    required LocalDate from,
    required LocalDate through,
    required bool unpaidOnly,
    bool overdueBefore = false,
  }) => _db
      .customSelect(
        _duesSql,
        variables: [
          Variable<DateTime>(from.toUtcMidnight()),
          Variable<DateTime>(through.toUtcMidnight()),
          Variable.withBool(unpaidOnly),
          Variable.withBool(overdueBefore),
        ],
        readsFrom: {_db.obligationInstances, _db.obligations, _db.transactions, _db.accounts},
      )
      .map(
        (row) => ObligationDueView(
          instance: _db.obligationInstances.map(row.data),
          obligationName: row.read<String>('obligation_name'),
          categoryId: row.read<int>('obligation_category_id'),
          accountId: row.readNullable<int>('obligation_account_id'),
          amountType: ObligationAmountType.values.byName(
            row.read<String>('obligation_amount_type'),
          ),
          paidAmount: row.read<int>('paid_amount'),
          lastPaidAt: row.readNullable<DateTime>('last_paid_date'),
          lastPaidAccountName: row.readNullable<String>('last_paid_account'),
        ),
      );

  /// Semua jatuh tempo yang belum lunas sampai [through] (ikut), termasuk yang
  /// sudah lewat. Inilah yang dicadangkan Safe-to-Spend.
  Future<List<ObligationDueView>> unpaidThrough(LocalDate through) =>
      _dues(from: _beginningOfTime, through: through, unpaidOnly: true).get();

  /// Uang kewajiban yang masih dicadangkan tepat sebelum [before]: jatuh tempo
  /// sampai [through] (ikut) dikurangi pembayaran sebelum [before]. Jatuh tempo
  /// yang ditandai lunas dihitung lunas kalau pembayaran terakhirnya sebelum
  /// [before].
  Future<int> reservedAsOf({required LocalDate through, required DateTime before}) async {
    final row = await _db
        .customSelect(
          '''
          SELECT COALESCE(SUM(CASE
              WHEN x.status = 'skipped' THEN 0
              WHEN x.status = 'paid' AND (x.last_paid IS NULL OR x.last_paid < unixepoch(?2)) THEN 0
              ELSE MAX(0, x.expected_amount - x.paid_before)
            END), 0) AS reserved
          FROM (
            SELECT i.status, i.expected_amount,
              COALESCE((SELECT SUM(t.amount) FROM transactions t
                        WHERE t.obligation_instance_id = i.id AND t.type = 'expense'
                          AND unixepoch(t.date) < unixepoch(?2)), 0) AS paid_before,
              (SELECT MAX(unixepoch(t.date)) FROM transactions t
                WHERE t.obligation_instance_id = i.id AND t.type = 'expense') AS last_paid
            FROM obligation_instances i
            JOIN obligations o ON o.id = i.obligation_id
            WHERE o.active = 1 AND i.due_date <= ?1
          ) x''',
          variables: [Variable<DateTime>(through.toUtcMidnight()), Variable<DateTime>(before)],
          readsFrom: {_db.obligationInstances, _db.obligations, _db.transactions},
        )
        .getSingle();
    return row.read<int>('reserved');
  }

  /// Semua jatuh tempo (apa pun statusnya) di antara [from] dan [through].
  Stream<List<ObligationDueView>> watchBetween(LocalDate from, LocalDate through) =>
      _dues(from: from, through: through, unpaidOnly: false).watch();

  /// Timeline layar 08: semua jatuh tempo yang dicadangkan dari [cycle]
  /// (setelah gajian pembuka sampai tepat di gajian berikutnya), ditambah
  /// jatuh tempo siklus sebelumnya yang belum lunas.
  Stream<List<ObligationDueView>> watchCycle(PayCycle cycle) => _dues(
    from: cycle.start.addDays(1),
    through: cycle.nextPayday,
    unpaidOnly: false,
    overdueBefore: true,
  ).watch();

  /// Mencatat pembayaran jatuh tempo sebagai transaksi pengeluaran.
  ///
  /// Status otomatis menjadi lunas kalau total pembayaran sudah menutup nominal.
  /// [markPaid] memaksa lunas walau nominalnya kurang, mis. tagihan listrik
  /// yang ternyata lebih kecil dari estimasi.
  Future<int> recordPayment({
    required int instanceId,
    required int accountId,
    required int amount,
    required DateTime date,
    String note = '',
    bool markPaid = false,
  }) {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount', 'harus lebih dari 0');
    return _db.transaction(() async {
      final instance = await (_db.select(
        _db.obligationInstances,
      )..where((i) => i.id.equals(instanceId))).getSingle();
      final obligation = await (_db.select(
        _db.obligations,
      )..where((o) => o.id.equals(instance.obligationId))).getSingle();
      final transactionId = await _db
          .into(_db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: TransactionType.expense,
              amount: amount,
              accountId: accountId,
              categoryId: Value(obligation.categoryId),
              date: date,
              note: Value(note.trim().isEmpty ? obligation.name : note.trim()),
              obligationInstanceId: Value(instanceId),
            ),
          );
      await refreshObligationStatus(_db, instanceId, forcePaid: markPaid);
      return transactionId;
    });
  }

  /// Lewati jatuh tempo ini (mis. langganan dijeda); tidak lagi dicadangkan.
  Future<void> skip(int instanceId) =>
      (_db.update(_db.obligationInstances)..where((i) => i.id.equals(instanceId))).write(
        const ObligationInstancesCompanion(status: Value(ObligationStatus.skipped)),
      );

  static LocalDate _later(LocalDate a, LocalDate b) => a > b ? a : b;
}

/// Menyelaraskan status jatuh tempo dengan pembayaran yang tercatat.
///
/// Dipanggil setelah pembayaran ditambah, diubah, atau dihapus. Jatuh tempo
/// yang dilewati (`skipped`) tidak disentuh.
Future<void> refreshObligationStatus(
  AppDatabase db,
  int instanceId, {
  bool forcePaid = false,
}) async {
  final instance = await (db.select(
    db.obligationInstances,
  )..where((i) => i.id.equals(instanceId))).getSingleOrNull();
  if (instance == null || instance.status == ObligationStatus.skipped) return;

  final paidSum = db.transactions.amount.sum();
  final row =
      await (db.selectOnly(db.transactions)
            ..addColumns([paidSum])
            ..where(
              db.transactions.obligationInstanceId.equals(instanceId) &
                  db.transactions.type.equalsValue(TransactionType.expense),
            ))
          .getSingle();
  final paid = row.read(paidSum) ?? 0;

  final ObligationStatus next;
  if (forcePaid || paid >= instance.expectedAmount) {
    next = ObligationStatus.paid;
  } else if (instance.status == ObligationStatus.paid) {
    next = ObligationStatus.pending;
  } else {
    next = instance.status;
  }
  if (next != instance.status) {
    await (db.update(db.obligationInstances)..where((i) => i.id.equals(instanceId))).write(
      ObligationInstancesCompanion(status: Value(next)),
    );
  }
}
