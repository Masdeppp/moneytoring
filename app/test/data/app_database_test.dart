import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/model/enums.dart';
import 'package:keuangan_app/data/db/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> insertAccount() => db
      .into(db.accounts)
      .insert(AccountsCompanion.insert(name: 'GoPay', type: AccountType.ewallet, icon: 'wallet'));

  test('kategori bawaan dibuat saat database pertama kali dibuat', () async {
    final rows = await db.select(db.categories).get();

    expect(rows, hasLength(defaultCategories.length));
    expect(rows.map((r) => r.name).toSet(), hasLength(rows.length), reason: 'nama unik');
    expect(rows.where((r) => r.type == CategoryType.income).map((r) => r.name), contains('Gaji'));
    expect(rows.map((r) => r.sortOrder), orderedEquals(List.generate(rows.length, (i) => i)));
  });

  test('transaksi tersimpan lengkap dengan enum dan tanggal', () async {
    final accountId = await insertAccount();
    final food = await (db.select(
      db.categories,
    )..where((c) => c.name.equals('Makan & minum'))).getSingle();

    final id = await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            type: TransactionType.expense,
            amount: 25000,
            accountId: accountId,
            categoryId: Value(food.id),
            date: DateTime(2026, 11, 11, 12, 30),
            note: const Value('makan siang'),
            categorySource: const Value(CategorySource.dictionary),
          ),
        );

    final row = await (db.select(db.transactions)..where((t) => t.id.equals(id))).getSingle();
    expect(row.type, TransactionType.expense);
    expect(row.amount, 25000);
    expect(row.date, DateTime(2026, 11, 11, 12, 30));
    expect(row.categorySource, CategorySource.dictionary);
    expect(row.obligationInstanceId, isNull);
  });

  test('foreign key aktif: akun yang tidak ada ditolak', () async {
    await expectLater(
      db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: TransactionType.expense,
              amount: 25000,
              accountId: 999,
              date: DateTime(2026, 11, 11),
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('nominal nol atau negatif ditolak', () async {
    final accountId = await insertAccount();
    await expectLater(
      db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: TransactionType.expense,
              amount: 0,
              accountId: accountId,
              date: DateTime(2026, 11, 11),
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('menghapus kewajiban ikut menghapus instance, transaksi tetap ada', () async {
    final accountId = await insertAccount();
    final bills = await (db.select(
      db.categories,
    )..where((c) => c.name.equals('Tagihan & utilitas'))).getSingle();
    final obligationId = await db
        .into(db.obligations)
        .insert(
          ObligationsCompanion.insert(
            name: 'Listrik',
            amountType: ObligationAmountType.estimated,
            amount: 300000,
            dueDay: 20,
            categoryId: bills.id,
          ),
        );
    final instanceId = await db
        .into(db.obligationInstances)
        .insert(
          ObligationInstancesCompanion.insert(
            obligationId: obligationId,
            cycleStart: DateTime(2026, 10, 25),
            dueDate: DateTime(2026, 11, 20),
            expectedAmount: 300000,
          ),
        );
    final txId = await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            type: TransactionType.expense,
            amount: 312000,
            accountId: accountId,
            categoryId: Value(bills.id),
            date: DateTime(2026, 11, 18),
            obligationInstanceId: Value(instanceId),
          ),
        );

    await (db.delete(db.obligations)..where((o) => o.id.equals(obligationId))).go();

    expect(await db.select(db.obligationInstances).get(), isEmpty);
    final tx = await (db.select(db.transactions)..where((t) => t.id.equals(txId))).getSingle();
    expect(tx.obligationInstanceId, isNull);
  });

  test('konfigurasi siklus gajian hanya boleh satu baris', () async {
    await db
        .into(db.payCycleConfigs)
        .insert(
          PayCycleConfigsCompanion.insert(paydayRule: PaydayRule.fixedDate, day: const Value(25)),
        );
    await expectLater(
      db
          .into(db.payCycleConfigs)
          .insert(
            PayCycleConfigsCompanion.insert(id: const Value(2), paydayRule: PaydayRule.lastWorkday),
          ),
      throwsA(isA<SqliteException>()),
    );
  });
}
