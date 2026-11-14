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
import 'package:keuangan_app/features/transactions/application/day_groups.dart';

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

    test('jenis akun bisa diganti tanpa mengubah kolom lain', () async {
      final id = await accounts.create(
        name: 'Dompet',
        type: AccountType.cash,
        icon: 'banknote',
        initialBalance: 50000,
      );
      await accounts.update(id, type: AccountType.ewallet, icon: 'wallet', tone: Tone.violet);

      final account = (await accounts.balances()).single.account;
      expect(account.type, AccountType.ewallet);
      expect(account.icon, 'wallet');
      expect(account.tone, Tone.violet);
      expect(account.name, 'Dompet');
      expect(account.initialBalance, 50000);
    });

    test('sesuaikan saldo: selisih masuk ke saldo awal, bukan jadi transaksi', () async {
      final id = await accounts.create(
        name: 'BCA',
        type: AccountType.bank,
        icon: 'landmark',
        initialBalance: 1000000,
      );
      await transactions.add(
        NewTransaction.expense(
          amount: 200000,
          accountId: id,
          categoryId: foodId,
          date: DateTime(2026, 11, 11, 9),
        ),
      );

      // Saldo tercatat 800 rb, di bank ternyata 750 rb.
      expect(await accounts.adjustBalance(id, 750000), -50000);
      var entry = (await accounts.balances()).single;
      expect(entry.balance, 750000);
      expect(entry.account.initialBalance, 950000);
      expect(await db.select(db.transactions).get(), hasLength(1));

      expect(await accounts.adjustBalance(id, 900000), 150000);
      expect((await accounts.balances()).single.balance, 900000);

      // Sudah sama: tidak ada yang berubah.
      expect(await accounts.adjustBalance(id, 900000), 0);
      entry = (await accounts.balances()).single;
      expect(entry.account.initialBalance, 1100000);

      await expectLater(accounts.adjustBalance(999, 1), throwsStateError);
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

    test('ubah nama, ikon, atau warna; jenis dan kolom lain tetap', () async {
      final id = await categories.create(
        name: 'Hewan',
        type: CategoryType.expense,
        icon: 'paw-print',
        tone: Tone.amber,
      );
      Future<CategoryRecord> read() async =>
          (await categories.active()).firstWhere((c) => c.id == id);

      await categories.update(id, name: '  Hewan peliharaan ');
      var category = await read();
      expect(category.name, 'Hewan peliharaan');
      expect(category.icon, 'paw-print');
      expect(category.tone, Tone.amber);

      await categories.update(id, icon: 'gift', tone: Tone.violet);
      category = await read();
      expect(category.name, 'Hewan peliharaan');
      expect(category.icon, 'gift');
      expect(category.tone, Tone.violet);
      expect(category.type, CategoryType.expense);

      await expectLater(categories.update(id, name: '   '), throwsArgumentError);
      await expectLater(categories.update(999, name: 'X'), throwsStateError);
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

  group('Quick Add: transaksi terbaru, kategori dan akun terakhir', () {
    late int bca;
    late int gopay;
    late int transportId;

    setUp(() async {
      bca = await accounts.create(name: 'BCA', type: AccountType.bank, icon: 'landmark');
      gopay = await accounts.create(name: 'GoPay', type: AccountType.ewallet, icon: 'wallet');
      transportId = (await categories.active()).firstWhere((c) => c.name == 'Transportasi').id;
    });

    test('transaksi terbaru lengkap dengan akun, akun tujuan, dan kategori', () async {
      await transactions.add(
        NewTransaction.expense(
          amount: 25000,
          accountId: gopay,
          categoryId: foodId,
          date: DateTime(2026, 11, 11, 12),
          note: 'Makan siang',
        ),
      );
      await transactions.add(
        NewTransaction.transfer(
          amount: 100000,
          fromAccountId: bca,
          toAccountId: gopay,
          date: DateTime(2026, 11, 11, 9),
        ),
      );
      await transactions.add(
        NewTransaction.expense(
          amount: 18000,
          accountId: gopay,
          categoryId: transportId,
          date: DateTime(2026, 11, 10, 8),
        ),
      );

      final recent = await transactions.watchRecent(limit: 2).first;
      expect(recent.map((v) => v.transaction.amount), [25000, 100000]);
      expect(recent.first.account.name, 'GoPay');
      expect(recent.first.category?.name, 'Makan & minum');
      expect(recent.first.toAccount, isNull);
      expect(recent.last.category, isNull);
      expect(recent.last.toAccount?.name, 'GoPay');
    });

    test('kategori dan akun yang terakhir dipakai ada di depan', () async {
      Future<void> spend(int categoryId, int accountId, DateTime date) => transactions.add(
        NewTransaction.expense(
          amount: 10000,
          accountId: accountId,
          categoryId: categoryId,
          date: date,
        ),
      );
      expect(await transactions.recentCategoryIds(TransactionType.expense), isEmpty);
      expect(await transactions.lastUsedAccountId(TransactionType.expense), isNull);

      await spend(foodId, bca, DateTime(2026, 11, 9));
      await spend(transportId, gopay, DateTime(2026, 11, 11));
      await spend(foodId, bca, DateTime(2026, 11, 10));

      expect(await transactions.recentCategoryIds(TransactionType.expense), [transportId, foodId]);
      expect(await transactions.recentCategoryIds(TransactionType.income), isEmpty);
      expect(await transactions.lastUsedAccountId(TransactionType.expense), gopay);
    });

    test('kategori semua termasuk arsip', () async {
      await categories.archive(foodId);
      final all = await categories.watchAll().first;
      expect(all.map((c) => c.id), contains(foodId));
    });
  });

  group('Daftar transaksi (layar 07): filter, pencarian, per hari, total', () {
    late int bca;
    late int gopay;
    late int transportId;

    Future<void> expense(int amount, int account, int category, DateTime date, String note) =>
        transactions.add(
          NewTransaction.expense(
            amount: amount,
            accountId: account,
            categoryId: category,
            date: date,
            note: note,
          ),
        );

    Future<List<int>> amounts(TransactionFilter filter, {int limit = 100}) async => [
      for (final view in await transactions.watchFiltered(filter, limit: limit).first)
        view.transaction.amount,
    ];

    setUp(() async {
      bca = await accounts.create(name: 'BCA', type: AccountType.bank, icon: 'landmark');
      gopay = await accounts.create(name: 'GoPay', type: AccountType.ewallet, icon: 'wallet');
      transportId = (await categories.active()).firstWhere((c) => c.name == 'Transportasi').id;

      await expense(25000, gopay, foodId, DateTime(2026, 11, 11, 12), 'Makan siang');
      await expense(18000, gopay, transportId, DateTime(2026, 11, 11, 8), 'Ojek ke kantor');
      await expense(12000, bca, foodId, DateTime(2026, 11, 10, 15), 'Kopi susu');
      await transactions.add(
        NewTransaction.transfer(
          amount: 100000,
          fromAccountId: bca,
          toAccountId: gopay,
          date: DateTime(2026, 11, 10, 9),
        ),
      );
      await expense(50000, bca, foodId, DateTime(2026, 11, 9, 19), 'Diskon 50%_promo');
      await transactions.add(
        NewTransaction.income(
          amount: 6000000,
          accountId: bca,
          categoryId: salaryId,
          date: DateTime(2026, 10, 25, 9),
        ),
      );
      await expense(99000, bca, foodId, DateTime(2026, 10, 20, 10), 'Bulan lalu');
    });

    test('filter jenis, akun (termasuk transfer masuk), kategori, dan gabungannya', () async {
      expect(await amounts(TransactionFilter.none), [
        25000,
        18000,
        12000,
        100000,
        50000,
        6000000,
        99000,
      ]);
      expect(await amounts(const TransactionFilter(type: TransactionType.income)), [6000000]);
      expect(await amounts(TransactionFilter(accountId: gopay)), [25000, 18000, 100000]);
      expect(await amounts(TransactionFilter(categoryId: foodId)), [25000, 12000, 50000, 99000]);
      expect(await amounts(TransactionFilter(type: TransactionType.expense, accountId: bca)), [
        12000,
        50000,
        99000,
      ]);
    });

    test('pencarian catatan, kategori, akun, dan nominal tanpa beda huruf besar/kecil', () async {
      Future<List<int>> search(String query) => amounts(TransactionFilter(query: query));
      expect(await search('KOPI'), [12000]);
      expect(await search('transport'), [18000]);
      expect(await search('gopay'), [25000, 18000, 100000]);
      expect(await search('ojek ke'), [18000]);
      expect(await search('25.000'), [25000]);
      expect(await search('Rp 6.000.000'), [6000000]);
      expect(await search('  '), hasLength(7));
      // `%` dan `_` dicari apa adanya, bukan sebagai wildcard LIKE.
      expect(await search('%'), [50000]);
      expect(await search('0%_p'), [50000]);
      expect(await amounts(TransactionFilter(query: 'makan', accountId: bca)), [
        12000,
        50000,
        99000,
      ]);
    });

    test('batas halaman memotong dari yang terbaru', () async {
      expect(await amounts(TransactionFilter.none, limit: 2), [25000, 18000]);
    });

    test('dikelompokkan per hari; total harian tanpa transfer', () async {
      final views = await transactions.watchFiltered(TransactionFilter.none, limit: 100).first;
      final days = groupByDay(views, truncated: false);
      expect(days.map((d) => d.date), [
        LocalDate(2026, 11, 11),
        LocalDate(2026, 11, 10),
        LocalDate(2026, 11, 9),
        LocalDate(2026, 10, 25),
        LocalDate(2026, 10, 20),
      ]);
      expect(days.map((d) => d.net), [-43000, -12000, -50000, 6000000, -99000]);
      expect(days.every((d) => d.complete), isTrue);

      // Halaman terpotong di tengah 10 Nov: total hari itu belum bisa ditampilkan.
      final partial = groupByDay(views.take(3).toList(), truncated: true);
      expect(partial.last.date, LocalDate(2026, 11, 10));
      expect(partial.last.complete, isFalse);
      expect(partial.first.complete, isTrue);

      final transfers = await transactions
          .watchFiltered(const TransactionFilter(type: TransactionType.transfer), limit: 100)
          .first;
      expect(groupByDay(transfers, truncated: false).single.hasCashFlow, isFalse);
      expect(groupByDay(const [], truncated: true), isEmpty);
    });

    test('total pemasukan dan pengeluaran satu siklus, tanpa transfer', () async {
      final totals = await transactions
          .watchTotals(DateTime(2026, 10, 25), DateTime(2026, 11, 25))
          .first;
      expect(totals, (income: 6000000, expense: 25000 + 18000 + 12000 + 50000));
      expect(await transactions.watchTotals(DateTime(2027), DateTime(2027, 2)).first, (
        income: 0,
        expense: 0,
      ));
    });

    test('filter sama jika isinya sama (kunci provider)', () {
      expect(
        const TransactionFilter(type: TransactionType.expense, query: 'a'),
        const TransactionFilter(type: TransactionType.expense).withQuery('a'),
      );
      expect(TransactionFilter(accountId: bca).withAccount(null), TransactionFilter.none);
      expect(TransactionFilter.none.isEmpty, isTrue);
      expect(const TransactionFilter(query: 'x').hasSelection, isFalse);
      expect(TransactionFilter(categoryId: foodId).hasSelection, isTrue);
    });
  });

  group('SavingsRepository: target bernama dan setoran', () {
    late SavingsRepository savings;
    late int bca;
    late int vault;
    final cycleStart = LocalDate(2026, 10, 25);

    setUp(() async {
      savings = SavingsRepository(db);
      bca = await accounts.create(
        name: 'BCA',
        type: AccountType.bank,
        icon: 'landmark',
        initialBalance: 5000000,
      );
      vault = await accounts.create(
        name: 'Tabungan',
        type: AccountType.bank,
        icon: 'piggy-bank',
        includeInSafeToSpend: false,
      );
    });

    test('validasi: tenggat butuh nominal; tanpa tenggat butuh setoran per siklus', () {
      SavingsGoalInput input({
        String name = 'Laptop',
        int? target,
        LocalDate? deadline,
        int? perCycle,
      }) => (
        name: name,
        targetAmount: target,
        deadline: deadline,
        amountPerCycle: perCycle,
        accountId: null,
      );
      expect(() => savings.create(input(name: ' ', perCycle: 1)), throwsArgumentError);
      expect(() => savings.create(input(deadline: LocalDate(2027, 4, 20))), throwsArgumentError);
      expect(() => savings.create(input(target: 1000000)), throwsArgumentError);
      expect(() => savings.create(input(perCycle: 0)), throwsArgumentError);
      expect(() => savings.create(input(target: -1, perCycle: 1)), throwsArgumentError);
    });

    test('setoran ke rekening tujuan menjadi transfer; progres per siklus', () async {
      final laptop = await savings.create((
        name: ' Laptop ',
        targetAmount: 6000000,
        deadline: LocalDate(2027, 4, 20),
        amountPerCycle: 999, // diabaikan karena bertenggat
        accountId: vault,
      ));
      await savings.contribute(
        goalId: laptop,
        amount: 1200000,
        date: DateTime(2026, 10, 1, 9),
        fromAccountId: bca,
      );
      await savings.contribute(
        goalId: laptop,
        amount: 300000,
        date: DateTime(2026, 11, 2, 9),
        fromAccountId: bca,
      );

      final progress = (await savings.progress(cycleStart)).single;
      expect(progress.goal.name, 'Laptop');
      expect(progress.goal.amountPerCycle, isNull);
      expect(progress.deadline, LocalDate(2027, 4, 20));
      expect(progress.savedBeforeCycle, 1200000);
      expect(progress.savedThisCycle, 300000);
      expect(progress.keptInSafeToSpend, isFalse);
      expect(progress.accountName, 'Tabungan');

      final balances = {for (final b in await accounts.balances()) b.account.name: b.balance};
      expect(balances['BCA'], 3500000);
      expect(balances['Tabungan'], 1500000);
    });

    test('tanpa rekening: setoran hanya dicatat, uangnya tetap di saldo', () async {
      final darurat = await savings.create((
        name: 'Dana darurat',
        targetAmount: null,
        deadline: null,
        amountPerCycle: 500000,
        accountId: null,
      ));
      await savings.contribute(
        goalId: darurat,
        amount: 500000,
        date: DateTime(2026, 11, 5),
        fromAccountId: bca,
      );
      final progress = (await savings.progress(cycleStart)).single;
      expect(progress.keptInSafeToSpend, isTrue);
      expect(progress.savedThisCycle, 500000);
      expect(await db.select(db.transactions).get(), isEmpty);
    });

    test(
      'membatalkan setoran ikut menghapus transfernya; transfer dihapus = setoran hilang',
      () async {
        final goal = await savings.create((
          name: 'Liburan',
          targetAmount: null,
          deadline: null,
          amountPerCycle: 200000,
          accountId: vault,
        ));
        final first = await savings.contribute(
          goalId: goal,
          amount: 200000,
          date: DateTime(2026, 11, 2),
          fromAccountId: bca,
        );
        await savings.contribute(
          goalId: goal,
          amount: 100000,
          date: DateTime(2026, 11, 3),
          fromAccountId: bca,
        );
        expect(await savings.watchContributions(goal).first, hasLength(2));

        await savings.deleteContribution(first);
        expect(await db.select(db.transactions).get(), hasLength(1));

        final transfer = (await db.select(db.transactions).get()).single;
        await transactions.delete(transfer.id);
        expect(await savings.watchContributions(goal).first, isEmpty);
      },
    );

    test('arsip tidak lagi muncul; hapus target tidak menghapus transfernya', () async {
      final a = await savings.create((
        name: 'A',
        targetAmount: null,
        deadline: null,
        amountPerCycle: 100000,
        accountId: vault,
      ));
      final b = await savings.create((
        name: 'B',
        targetAmount: null,
        deadline: null,
        amountPerCycle: 100000,
        accountId: vault,
      ));
      await savings.contribute(
        goalId: b,
        amount: 100000,
        date: DateTime(2026, 11, 2),
        fromAccountId: bca,
      );
      await savings.archive(a);
      await savings.update(b, (
        name: 'B baru',
        targetAmount: 500000,
        deadline: LocalDate(2027, 1, 10),
        amountPerCycle: null,
        accountId: vault,
      ));
      expect((await savings.progress(cycleStart)).single.goal.name, 'B baru');

      await savings.delete(b);
      expect(await savings.progress(cycleStart), isEmpty);
      expect(await db.select(db.goalContributions).get(), isEmpty);
      expect(await db.select(db.transactions).get(), hasLength(1));
    });
  });
}
