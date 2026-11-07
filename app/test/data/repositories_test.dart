import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/model/enums.dart';
import 'package:keuangan_app/data/db/app_database.dart';
import 'package:keuangan_app/data/repositories/account_repository.dart';
import 'package:keuangan_app/data/repositories/category_repository.dart';
import 'package:keuangan_app/data/repositories/pay_cycle_repository.dart';
import 'package:keuangan_app/data/repositories/savings_repository.dart';
import 'package:keuangan_app/data/repositories/transaction_repository.dart';
import 'package:keuangan_app/engine/common/local_date.dart';
import 'package:keuangan_app/engine/cycle/pay_cycle.dart';

void main() {
  late AppDatabase db;
  late AccountRepository accounts;
  late CategoryRepository categories;
  late TransactionRepository transactions;
  late int foodId;
  late int salaryId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    accounts = AccountRepository(db);
    categories = CategoryRepository(db);
    transactions = TransactionRepository(db);
    final all = await categories.active();
    foodId = all.firstWhere((c) => c.name == 'Makan & minum').id;
    salaryId = all.firstWhere((c) => c.name == 'Gaji').id;
  });
  tearDown(() => db.close());

  group('AccountRepository', () {
    test('saldo = awal + masuk − keluar − transfer keluar + transfer masuk', () async {
      final bca = await accounts.create(
        name: 'BCA',
        type: AccountType.bank,
        icon: 'landmark',
        initialBalance: 1000000,
      );
      final gopay = await accounts.create(name: 'GoPay', type: AccountType.ewallet, icon: 'wallet');
      final date = DateTime(2026, 11, 11, 9);

      await transactions.add(
        NewTransaction.income(amount: 500000, accountId: bca, categoryId: salaryId, date: date),
      );
      await transactions.add(
        NewTransaction.expense(amount: 200000, accountId: bca, categoryId: foodId, date: date),
      );
      await transactions.add(
        NewTransaction.transfer(amount: 300000, fromAccountId: bca, toAccountId: gopay, date: date),
      );

      final balances = {for (final b in await accounts.balances()) b.account.name: b.balance};
      expect(balances, {'BCA': 1000000, 'GoPay': 300000});
      expect(await accounts.spendableBalance(), 1300000);

      await accounts.update(gopay, includeInSafeToSpend: false);
      expect(await accounts.spendableBalance(), 1000000);
    });

    test('akun baru berurutan; nama kosong ditolak', () async {
      final first = await accounts.create(
        name: ' Tunai ',
        type: AccountType.cash,
        icon: 'banknote',
      );
      await accounts.create(name: 'BCA', type: AccountType.bank, icon: 'landmark');

      final list = await accounts.balances();
      expect(list.map((b) => b.account.name), ['Tunai', 'BCA']);
      expect(list.map((b) => b.account.sortOrder), [0, 1]);
      expect(list.first.account.id, first);
      await expectLater(
        accounts.create(name: '  ', type: AccountType.cash, icon: 'banknote'),
        throwsArgumentError,
      );
    });

    test('ubah sebagian kolom; akun yang tidak ada ditolak', () async {
      final id = await accounts.create(name: 'BCA', type: AccountType.bank, icon: 'landmark');
      await accounts.update(id, name: 'BCA Utama', tone: Tone.blue, initialBalance: 250000);

      final account = (await accounts.balances()).single.account;
      expect(account.name, 'BCA Utama');
      expect(account.tone, Tone.blue);
      expect(account.icon, 'landmark');
      expect(account.initialBalance, 250000);
      await expectLater(accounts.update(999, name: 'X'), throwsStateError);
    });

    test('akun arsip disembunyikan tapi saldonya tetap bisa dilihat', () async {
      final id = await accounts.create(name: 'Lama', type: AccountType.cash, icon: 'banknote');
      await accounts.archive(id);

      expect(await accounts.balances(), isEmpty);
      expect(await accounts.balances(includeArchived: true), hasLength(1));
    });

    test('stream saldo ikut berubah saat transaksi dicatat', () async {
      final id = await accounts.create(
        name: 'Tunai',
        type: AccountType.cash,
        icon: 'banknote',
        initialBalance: 100000,
      );
      final balances = StreamIterator(accounts.watchBalances().map((list) => list.single.balance));
      addTearDown(balances.cancel);

      expect(await balances.moveNext(), isTrue);
      expect(balances.current, 100000);

      await transactions.add(
        NewTransaction.expense(
          amount: 25000,
          accountId: id,
          categoryId: foodId,
          date: DateTime(2026, 11, 11),
        ),
      );
      expect(await balances.moveNext(), isTrue);
      expect(balances.current, 75000);
    });
  });

  group('CategoryRepository', () {
    test('kategori aktif per jenis, kategori baru di urutan terakhir', () async {
      final expense = await categories.active(type: CategoryType.expense);
      final income = await categories.active(type: CategoryType.income);
      expect(expense.every((c) => c.type == CategoryType.expense), isTrue);
      expect(income.map((c) => c.name), ['Gaji', 'Bonus', 'Pemasukan lain']);

      final id = await categories.create(
        name: 'Hewan peliharaan',
        type: CategoryType.expense,
        icon: 'paw-print',
        tone: Tone.amber,
      );
      final updated = await categories.active(type: CategoryType.expense);
      expect(updated.last.id, id);
      expect(updated.last.isDefault, isFalse);

      await categories.archive(id);
      expect((await categories.active()).map((c) => c.id), isNot(contains(id)));
      await expectLater(
        categories.create(name: '', type: CategoryType.expense, icon: 'x', tone: Tone.red),
        throwsArgumentError,
      );
    });

    test('stream kategori', () async {
      expect(await categories.watchActive(type: CategoryType.income).first, hasLength(3));
    });
  });

  group('TransactionRepository', () {
    late int bca;
    late int savingsAccount;

    setUp(() async {
      bca = await accounts.create(name: 'BCA', type: AccountType.bank, icon: 'landmark');
      savingsAccount = await accounts.create(
        name: 'Dana darurat',
        type: AccountType.bank,
        icon: 'piggy-bank',
        includeInSafeToSpend: false,
      );
    });

    NewTransaction expense(int amount, DateTime date, {int? accountId}) => NewTransaction.expense(
      amount: amount,
      accountId: accountId ?? bca,
      categoryId: foodId,
      date: date,
    );

    test('validasi saat membuat transaksi', () {
      expect(() => expense(0, DateTime(2026, 11, 11)), throwsArgumentError);
      expect(
        () => NewTransaction.transfer(
          amount: 1000,
          fromAccountId: 1,
          toAccountId: 1,
          date: DateTime(2026, 11, 11),
        ),
        throwsArgumentError,
      );
    });

    test(
      'belanja harian hanya pengeluaran biasa dari akun Safe-to-Spend, per tanggal lokal',
      () async {
        await transactions.add(expense(10000, DateTime(2026, 11, 4, 23, 59))); // sebelum rentang
        await transactions.add(expense(20000, DateTime(2026, 11, 5))); // awal rentang
        await transactions.add(expense(30000, DateTime(2026, 11, 11, 23, 59))); // akhir rentang
        await transactions.add(expense(40000, DateTime(2026, 11, 12))); // sesudah rentang
        await transactions.add(expense(50000, DateTime(2026, 11, 6), accountId: savingsAccount));
        await transactions.add(
          NewTransaction.income(
            amount: 60000,
            accountId: bca,
            categoryId: salaryId,
            date: DateTime(2026, 11, 6),
          ),
        );
        await transactions.add(
          NewTransaction.transfer(
            amount: 70000,
            fromAccountId: bca,
            toAccountId: savingsAccount,
            date: DateTime(2026, 11, 6),
          ),
        );

        final entries = await transactions.spending(
          from: LocalDate(2026, 11, 5),
          to: LocalDate(2026, 11, 11),
        );
        expect(
          {for (final e in entries) e.date.toString(): e.amount},
          {'2026-11-05': 20000, '2026-11-11': 30000},
        );
      },
    );

    test('transfer ke rekening tabungan dijumlah per rentang', () async {
      Future<void> transfer(int amount, DateTime date) => transactions.add(
        NewTransaction.transfer(
          amount: amount,
          fromAccountId: bca,
          toAccountId: savingsAccount,
          date: date,
        ),
      );
      await transfer(100000, DateTime(2026, 10, 30));
      await transfer(150000, DateTime(2026, 11, 10));
      await transfer(999999, DateTime(2026, 10, 1)); // sebelum siklus

      expect(
        await transactions.transferredInto(
          accountIds: {savingsAccount},
          from: LocalDate(2026, 10, 25),
          to: LocalDate(2026, 11, 11),
        ),
        250000,
      );
      expect(
        await transactions.transferredInto(
          accountIds: {},
          from: LocalDate(2026, 10, 25),
          to: LocalDate(2026, 11, 11),
        ),
        0,
      );
    });

    test('daftar transaksi per rentang waktu, terbaru dulu; ubah dan hapus', () async {
      final older = await transactions.add(expense(10000, DateTime(2026, 11, 10, 8)));
      final newer = await transactions.add(expense(20000, DateTime(2026, 11, 11, 8)));
      await transactions.add(expense(30000, DateTime(2026, 11, 20)));

      Stream<List<TransactionRecord>> inRange() =>
          transactions.watchBetween(DateTime(2026, 11, 10), DateTime(2026, 11, 12));
      expect((await inRange().first).map((t) => t.id), [newer, older]);

      await transactions.replace(older, expense(15000, DateTime(2026, 11, 10, 8)));
      await transactions.delete(newer);
      expect((await inRange().first).single.amount, 15000);
    });
  });

  group('PayCycleRepository', () {
    late PayCycleRepository payCycles;
    setUp(() => payCycles = PayCycleRepository(db));

    test('simpan pertama butuh tanggal mulai mencatat; sesudahnya tanggal itu tetap', () async {
      expect(await payCycles.current(), isNull);
      await expectLater(
        payCycles.save(rule: PayCycleRule.fixedDate(25), expectedIncome: 7500000),
        throwsArgumentError,
      );

      await payCycles.save(
        rule: PayCycleRule.fixedDate(25),
        expectedIncome: 7500000,
        trackingSince: LocalDate(2026, 11, 7),
      );
      await payCycles.save(
        rule: const PayCycleRule.lastWorkday(),
        expectedIncome: 8000000,
        bufferBasisPoints: 300,
      );

      final config = (await payCycles.current())!;
      expect(config.paydayRule, PaydayRule.lastWorkday);
      expect(config.day, isNull);
      expect(config.expectedIncome, 8000000);
      expect(config.bufferBasisPoints, 300);
      expect(LocalDate.fromDateTime(config.trackingSince), LocalDate(2026, 11, 7));
      expect(PayCycleRepository.ruleOf(config).rule, PaydayRule.lastWorkday);
      expect(await payCycles.watch().first, isNotNull);
    });

    test('nilai tidak valid ditolak', () {
      expect(
        () => payCycles.save(rule: PayCycleRule.fixedDate(25), expectedIncome: -1),
        throwsArgumentError,
      );
      expect(
        () => payCycles.save(
          rule: PayCycleRule.fixedDate(25),
          expectedIncome: 0,
          bufferBasisPoints: 10001,
        ),
        throwsRangeError,
      );
    });
  });

  group('SavingsRepository', () {
    test('satu target per siklus; 0 menghapus target', () async {
      final savings = SavingsRepository(db);
      await savings.setTarget(amountPerCycle: 500000);
      await savings.setTarget(amountPerCycle: 750000);
      expect((await savings.targets()).single.amountPerCycle, 750000);

      await savings.setTarget(amountPerCycle: 0);
      expect(await savings.targets(), isEmpty);
      expect(() => savings.setTarget(amountPerCycle: -1), throwsArgumentError);
    });
  });
}
