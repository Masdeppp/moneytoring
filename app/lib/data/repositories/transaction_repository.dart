import 'package:drift/drift.dart';

import '../../core/model/enums.dart';
import '../../engine/common/local_date.dart';
import '../../engine/forecast/risk_tier0.dart';
import '../db/app_database.dart';
import 'obligation_repository.dart';

/// Transaksi baru dari layar tambah transaksi. Dibuat lewat konstruktor per
/// jenis supaya kombinasi kolom yang tidak valid tidak bisa terjadi.
final class NewTransaction {
  NewTransaction.expense({
    required this.amount,
    required this.accountId,
    required int this.categoryId,
    required this.date,
    this.note = '',
    this.categorySource,
  }) : type = TransactionType.expense,
       toAccountId = null {
    _checkAmount();
  }

  NewTransaction.income({
    required this.amount,
    required this.accountId,
    required int this.categoryId,
    required this.date,
    this.note = '',
    this.categorySource,
  }) : type = TransactionType.income,
       toAccountId = null {
    _checkAmount();
  }

  NewTransaction.transfer({
    required this.amount,
    required int fromAccountId,
    required int this.toAccountId,
    required this.date,
    this.note = '',
  }) : type = TransactionType.transfer,
       accountId = fromAccountId,
       categoryId = null,
       categorySource = null {
    _checkAmount();
    if (fromAccountId == toAccountId) {
      throw ArgumentError.value(toAccountId, 'toAccountId', 'harus berbeda dari akun asal');
    }
  }

  final TransactionType type;
  final int amount;
  final int accountId;
  final int? toAccountId;
  final int? categoryId;
  final DateTime date;
  final String note;
  final CategorySource? categorySource;

  void _checkAmount() {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount', 'harus lebih dari 0');
  }

  TransactionsCompanion toCompanion() => TransactionsCompanion.insert(
    type: type,
    amount: amount,
    accountId: accountId,
    toAccountId: Value(toAccountId),
    categoryId: Value(categoryId),
    date: date,
    note: Value(note.trim()),
    categorySource: Value(categorySource),
  );
}

/// Pencatatan pemasukan, pengeluaran, dan transfer (PRD §7.1).
class TransactionRepository {
  TransactionRepository(this._db);

  final AppDatabase _db;

  Future<int> add(NewTransaction transaction) =>
      _db.into(_db.transactions).insert(transaction.toCompanion());

  /// Mengganti isi transaksi. Hubungan ke jatuh tempo kewajiban dipertahankan
  /// dan statusnya diselaraskan ulang.
  Future<void> replace(int id, NewTransaction transaction) => _db.transaction(() async {
    final existing = await _byId(id);
    await (_db.update(
      _db.transactions,
    )..where((t) => t.id.equals(id))).write(transaction.toCompanion());
    final instanceId = existing.obligationInstanceId;
    if (instanceId != null) await refreshObligationStatus(_db, instanceId);
  });

  /// Menghapus transaksi. Kalau itu pembayaran kewajiban, jatuh temponya
  /// kembali belum lunas bila pembayarannya tidak lagi cukup.
  Future<void> delete(int id) => _db.transaction(() async {
    final existing = await _byId(id);
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
    final instanceId = existing.obligationInstanceId;
    if (instanceId != null) await refreshObligationStatus(_db, instanceId);
  });

  Future<TransactionRecord> _byId(int id) =>
      (_db.select(_db.transactions)..where((t) => t.id.equals(id))).getSingle();

  /// Transaksi dengan waktu di antara [from] (ikut) dan [until] (tidak ikut),
  /// terbaru dulu.
  Stream<List<TransactionRecord>> watchBetween(DateTime from, DateTime until) =>
      (_db.select(_db.transactions)
            ..where((t) => _inRange(t.date, from, until))
            ..orderBy([(t) => OrderingTerm.desc(t.date.unixepoch), (t) => OrderingTerm.desc(t.id)]))
          .watch();

  /// Belanja harian untuk engine risiko: pengeluaran dari akun yang dihitung
  /// di Safe-to-Spend, tanpa pembayaran kewajiban, dari [from] sampai [to].
  Future<List<SpendEntry>> spending({required LocalDate from, required LocalDate to}) async {
    final t = _db.transactions;
    final a = _db.accounts;
    final query = _db.selectOnly(t).join([innerJoin(a, a.id.equalsExp(t.accountId))])
      ..addColumns([t.date, t.amount])
      ..where(
        t.type.equalsValue(TransactionType.expense) &
            t.obligationInstanceId.isNull() &
            a.includeInSafeToSpend.equals(true) &
            _inRange(t.date, from.toDateTime(), to.addDays(1).toDateTime()),
      );
    return [
      for (final row in await query.get())
        SpendEntry(LocalDate.fromDateTime(row.read(t.date)!.toLocal()), row.read(t.amount)!),
    ];
  }

  /// Total transfer dari akun Safe-to-Spend ke [accountIds] antara [from] dan
  /// [to] (ikut). Dipakai untuk menghitung tabungan yang sudah disisihkan.
  Future<int> transferredInto({
    required Set<int> accountIds,
    required LocalDate from,
    required LocalDate to,
  }) async {
    if (accountIds.isEmpty) return 0;
    final t = _db.transactions;
    final a = _db.accounts;
    final total = t.amount.sum();
    final query = _db.selectOnly(t).join([innerJoin(a, a.id.equalsExp(t.accountId))])
      ..addColumns([total])
      ..where(
        t.type.equalsValue(TransactionType.transfer) &
            t.toAccountId.isIn(accountIds) &
            a.includeInSafeToSpend.equals(true) &
            _inRange(t.date, from.toDateTime(), to.addDays(1).toDateTime()),
      );
    return (await query.getSingle()).read(total) ?? 0;
  }

  // Waktu transaksi disimpan sebagai teks ISO dengan offset zona waktu;
  // unixepoch() membandingkannya dengan benar walau offset-nya berbeda.
  static Expression<bool> _inRange(Expression<DateTime> date, DateTime from, DateTime until) =>
      date.unixepoch.isBiggerOrEqualValue(_seconds(from)) &
      date.unixepoch.isSmallerThanValue(_seconds(until));

  static int _seconds(DateTime time) => time.millisecondsSinceEpoch ~/ 1000;
}
