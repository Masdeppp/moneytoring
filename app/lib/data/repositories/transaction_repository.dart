import 'package:drift/drift.dart';

import '../../core/model/enums.dart';
import '../../engine/common/local_date.dart';
import '../../engine/forecast/risk_tier0.dart';
import '../db/app_database.dart';
import 'obligation_repository.dart';

/// Transaksi beserta akun dan kategorinya, untuk ditampilkan di list.
final class TransactionView {
  const TransactionView({
    required this.transaction,
    required this.account,
    this.toAccount,
    this.category,
  });

  final TransactionRecord transaction;
  final AccountRecord account;

  /// Hanya untuk transfer.
  final AccountRecord? toAccount;

  /// Kosong untuk transfer.
  final CategoryRecord? category;
}

/// Filter daftar transaksi (layar 07). Semua kosong berarti semua transaksi.
final class TransactionFilter {
  const TransactionFilter({this.type, this.accountId, this.categoryId, this.query = ''});

  static const none = TransactionFilter();

  final TransactionType? type;

  /// Akun asal, atau akun tujuan untuk transfer.
  final int? accountId;
  final int? categoryId;

  /// Dicari di catatan, nama kategori, dan nama akun. Kalau isinya angka saja
  /// (mis. `25.000`), juga dicocokkan dengan nominal.
  final String query;

  /// Ada filter jenis, akun, atau kategori (pencarian tidak dihitung).
  bool get hasSelection => type != null || accountId != null || categoryId != null;

  bool get isEmpty => !hasSelection && query.trim().isEmpty;

  TransactionFilter withType(TransactionType? value) =>
      TransactionFilter(type: value, accountId: accountId, categoryId: categoryId, query: query);

  TransactionFilter withAccount(int? value) =>
      TransactionFilter(type: type, accountId: value, categoryId: categoryId, query: query);

  TransactionFilter withCategory(int? value) =>
      TransactionFilter(type: type, accountId: accountId, categoryId: value, query: query);

  TransactionFilter withQuery(String value) =>
      TransactionFilter(type: type, accountId: accountId, categoryId: categoryId, query: value);

  @override
  bool operator ==(Object other) =>
      other is TransactionFilter &&
      other.type == type &&
      other.accountId == accountId &&
      other.categoryId == categoryId &&
      other.query == query;

  @override
  int get hashCode => Object.hash(type, accountId, categoryId, query);
}

/// Total pemasukan dan pengeluaran dalam satu rentang waktu.
typedef CashFlowTotals = ({int income, int expense});

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

  /// [limit] transaksi terbaru beserta akun dan kategorinya (Beranda).
  Stream<List<TransactionView>> watchRecent({int limit = 3}) =>
      watchFiltered(TransactionFilter.none, limit: limit);

  /// Transaksi yang cocok dengan [filter], terbaru dulu, paling banyak [limit]
  /// baris (layar 07). Layar memuat per halaman supaya riwayat bertahun-tahun
  /// tidak dibaca sekaligus.
  Stream<List<TransactionView>> watchFiltered(TransactionFilter filter, {required int limit}) {
    final t = _db.transactions;
    final account = _db.accounts;
    final category = _db.categories;
    final query =
        _db.select(t).join([
            innerJoin(account, account.id.equalsExp(t.accountId)),
            leftOuterJoin(_toAccount, _toAccount.id.equalsExp(t.toAccountId)),
            leftOuterJoin(category, category.id.equalsExp(t.categoryId)),
          ])
          ..where(_matches(filter))
          ..orderBy([OrderingTerm.desc(t.date.unixepoch), OrderingTerm.desc(t.id)])
          ..limit(limit);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          TransactionView(
            transaction: row.readTable(t),
            account: row.readTable(account),
            toAccount: row.readTableOrNull(_toAccount),
            category: row.readTableOrNull(category),
          ),
      ],
    );
  }

  late final _toAccount = _db.alias(_db.accounts, 'to_account');

  Expression<bool> _matches(TransactionFilter filter) {
    final t = _db.transactions;
    return Expression.and([
      if (filter.type case final type?) t.type.equalsValue(type),
      if (filter.accountId case final id?) t.accountId.equals(id) | t.toAccountId.equals(id),
      if (filter.categoryId case final id?) t.categoryId.equals(id),
      ?_search(filter.query),
    ]);
  }

  /// Pencarian tanpa membedakan huruf besar/kecil. `%` dan `_` yang diketik
  /// pengguna dicari apa adanya, bukan sebagai wildcard LIKE.
  Expression<bool>? _search(String query) {
    final text = query.trim();
    if (text.isEmpty) return null;
    final pattern = '%${text.replaceAllMapped(RegExp(r'[\\%_]'), (m) => '\\${m[0]}')}%';
    Expression<bool> like(Expression<String> column) => column.like(pattern, escapeChar: r'\');

    final t = _db.transactions;
    var condition =
        like(t.note) | like(_db.accounts.name) | like(_toAccount.name) | like(_db.categories.name);
    final digits = text.toLowerCase().replaceAll(RegExp(r'^rp|[.\s]'), '');
    if (RegExp(r'^\d{1,13}$').hasMatch(digits)) {
      condition = condition | t.amount.equals(int.parse(digits));
    }
    return condition;
  }

  /// Total pemasukan dan pengeluaran dengan waktu di antara [from] (ikut) dan
  /// [until] (tidak ikut), dihitung di SQL. Transfer tidak dihitung.
  Stream<CashFlowTotals> watchTotals(DateTime from, DateTime until) {
    final t = _db.transactions;
    final income = t.amount.sum(filter: t.type.equalsValue(TransactionType.income));
    final expense = t.amount.sum(filter: t.type.equalsValue(TransactionType.expense));
    final query = _db.selectOnly(t)
      ..addColumns([income, expense])
      ..where(_inRange(t.date, from, until));
    return query.watchSingle().map(
      (row) => (income: row.read(income) ?? 0, expense: row.read(expense) ?? 0),
    );
  }

  /// Id kategori yang pernah dipakai untuk [type], yang terakhir dipakai
  /// paling depan (PRD §7.1 Quick Add). Pembayaran kewajiban tidak dihitung.
  Future<List<int>> recentCategoryIds(TransactionType type) async {
    final t = _db.transactions;
    final lastUsed = t.date.unixepoch.max();
    final query = _db.selectOnly(t)
      ..addColumns([t.categoryId, lastUsed])
      ..where(t.type.equalsValue(type) & t.categoryId.isNotNull() & t.obligationInstanceId.isNull())
      ..groupBy([t.categoryId])
      ..orderBy([OrderingTerm.desc(lastUsed), OrderingTerm.asc(t.categoryId)]);
    return [for (final row in await query.get()) row.read(t.categoryId)!];
  }

  /// Akun yang terakhir dipakai untuk [type]; `null` kalau belum pernah.
  Future<int?> lastUsedAccountId(TransactionType type) async {
    final row =
        await (_db.select(_db.transactions)
              ..where((t) => t.type.equalsValue(type))
              ..orderBy([
                (t) => OrderingTerm.desc(t.date.unixepoch),
                (t) => OrderingTerm.desc(t.id),
              ])
              ..limit(1))
            .getSingleOrNull();
    return row?.accountId;
  }

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
