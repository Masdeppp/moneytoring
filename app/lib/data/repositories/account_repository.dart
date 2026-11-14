import 'package:drift/drift.dart';

import '../../core/model/enums.dart';
import '../db/app_database.dart';

/// Akun beserta saldo terkini.
final class AccountBalance {
  const AccountBalance(this.account, this.balance);

  final AccountRecord account;

  /// Saldo awal + pemasukan − pengeluaran − transfer keluar + transfer masuk.
  final int balance;
}

/// Akun/dompet pengguna (Tunai, BCA, GoPay, …) dan saldonya.
class AccountRepository {
  AccountRepository(this._db);

  final AppDatabase _db;

  // Saldo dihitung dari transaksi, bukan disimpan, supaya tidak pernah
  // berbeda dengan riwayatnya.
  static const _balancesSql = '''
    SELECT a.*,
      a.initial_balance
        + COALESCE((SELECT SUM(CASE t.type WHEN 'income' THEN t.amount ELSE -t.amount END)
                    FROM transactions t WHERE t.account_id = a.id), 0)
        + COALESCE((SELECT SUM(t.amount) FROM transactions t
                    WHERE t.type = 'transfer' AND t.to_account_id = a.id), 0)
        AS balance
    FROM accounts a
    WHERE a.archived = 0 OR ?1
    ORDER BY a.sort_order, a.id''';

  Selectable<AccountBalance> _balances({required bool includeArchived}) => _db
      .customSelect(
        _balancesSql,
        variables: [Variable.withBool(includeArchived)],
        readsFrom: {_db.accounts, _db.transactions},
      )
      .map((row) => AccountBalance(_db.accounts.map(row.data), row.read<int>('balance')));

  Future<List<AccountBalance>> balances({bool includeArchived = false}) =>
      _balances(includeArchived: includeArchived).get();

  Stream<List<AccountBalance>> watchBalances({bool includeArchived = false}) =>
      _balances(includeArchived: includeArchived).watch();

  /// Total saldo akun aktif yang dihitung di Safe-to-Spend.
  Future<int> spendableBalance() async => (await balances())
      .where((entry) => entry.account.includeInSafeToSpend)
      .fold<int>(0, (sum, entry) => sum + entry.balance);

  /// Total saldo akun aktif yang dihitung di Safe-to-Spend, hanya dari
  /// transaksi sebelum [before]. Dipakai untuk menutup siklus yang sudah lewat.
  Future<int> spendableBalanceBefore(DateTime before) async {
    final row = await _db
        .customSelect(
          '''
          SELECT COALESCE(SUM(a.initial_balance
            + COALESCE((SELECT SUM(CASE t.type WHEN 'income' THEN t.amount ELSE -t.amount END)
                        FROM transactions t
                        WHERE t.account_id = a.id AND unixepoch(t.date) < unixepoch(?1)), 0)
            + COALESCE((SELECT SUM(t.amount) FROM transactions t
                        WHERE t.type = 'transfer' AND t.to_account_id = a.id
                          AND unixepoch(t.date) < unixepoch(?1)), 0)), 0) AS balance
          FROM accounts a
          WHERE a.archived = 0 AND a.include_in_safe_to_spend = 1''',
          variables: [Variable<DateTime>(before)],
          readsFrom: {_db.accounts, _db.transactions},
        )
        .getSingle();
    return row.read<int>('balance');
  }

  Future<int> create({
    required String name,
    required AccountType type,
    required String icon,
    int initialBalance = 0,
    Tone tone = Tone.brand,
    bool includeInSafeToSpend = true,
  }) async {
    final nextOrder = await _nextSortOrder();
    return _db
        .into(_db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: _checkName(name),
            type: type,
            icon: icon,
            initialBalance: Value(initialBalance),
            tone: Value(tone),
            includeInSafeToSpend: Value(includeInSafeToSpend),
            sortOrder: Value(nextOrder),
          ),
        );
  }

  /// Ubah sebagian kolom akun. Kolom yang tidak diisi tidak berubah.
  Future<void> update(
    int id, {
    String? name,
    AccountType? type,
    String? icon,
    Tone? tone,
    int? initialBalance,
    bool? includeInSafeToSpend,
  }) async {
    final updated = await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(
        name: name == null ? const Value.absent() : Value(_checkName(name)),
        type: Value.absentIfNull(type),
        icon: Value.absentIfNull(icon),
        tone: Value.absentIfNull(tone),
        initialBalance: Value.absentIfNull(initialBalance),
        includeInSafeToSpend: Value.absentIfNull(includeInSafeToSpend),
      ),
    );
    if (updated == 0) throw StateError('Akun $id tidak ditemukan');
  }

  /// Menyamakan saldo akun dengan [actualBalance] (saldo sebenarnya di bank
  /// atau dompet). Selisihnya masuk ke saldo awal, bukan menjadi transaksi,
  /// supaya total pemasukan dan pengeluaran tidak ikut berubah.
  ///
  /// Mengembalikan selisihnya (positif kalau saldo bertambah).
  Future<int> adjustBalance(int id, int actualBalance) => _db.transaction(() async {
    final entry = (await balances(includeArchived: true))
        .where((entry) => entry.account.id == id)
        .firstOrNull;
    if (entry == null) throw StateError('Akun $id tidak ditemukan');
    final difference = actualBalance - entry.balance;
    if (difference != 0) {
      await update(id, initialBalance: entry.account.initialBalance + difference);
    }
    return difference;
  });

  /// Akun diarsipkan, bukan dihapus, supaya riwayat transaksinya tetap utuh.
  Future<void> archive(int id) => (_db.update(
    _db.accounts,
  )..where((a) => a.id.equals(id))).write(const AccountsCompanion(archived: Value(true)));

  Future<int> _nextSortOrder() async {
    final max = _db.accounts.sortOrder.max();
    final row = await (_db.selectOnly(_db.accounts)..addColumns([max])).getSingle();
    return (row.read(max) ?? -1) + 1;
  }

  static String _checkName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError.value(name, 'name', 'tidak boleh kosong');
    return trimmed;
  }
}
