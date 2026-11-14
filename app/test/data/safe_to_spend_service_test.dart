import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/model/enums.dart';
import 'package:keuangan_app/data/db/app_database.dart';
import 'package:keuangan_app/data/db/database_provider.dart';
import 'package:keuangan_app/data/providers.dart';
import 'package:keuangan_app/data/repositories/transaction_repository.dart';
import 'package:keuangan_app/data/services/safe_to_spend_service.dart';
import 'package:keuangan_app/engine/common/local_date.dart';
import 'package:keuangan_app/engine/cycle/holiday_calendar.dart';
import 'package:keuangan_app/engine/cycle/pay_cycle.dart';

LocalDate d(int y, int m, int day) => LocalDate(y, m, day);

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late SafeToSpendService service;
  final today = d(2026, 11, 11);
  final rule = PayCycleRule.fixedDate(25, shiftOnHoliday: false);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 11, 10)),
        holidayCalendarProvider.overrideWithValue(const NoHolidays()),
      ],
    );
    service = container.read(safeToSpendServiceProvider);
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// Lampiran A PRD dibangun dari data: saldo akhir BCA Rp 3.000.000 setelah
  /// kewajiban Oktober dibayar dan belanja harian dicatat; kewajiban November
  /// Rp 2.200.000 belum dibayar.
  Future<({int bca, int food})> seedLampiranA() async {
    final categories = await container.read(categoryRepositoryProvider).active();
    int category(String name) => categories.firstWhere((c) => c.name == name).id;
    final food = category('Makan & minum');

    await container
        .read(payCycleRepositoryProvider)
        .save(rule: rule, expectedIncome: 7500000, trackingSince: d(2026, 10, 1));
    final bca = await container
        .read(accountRepositoryProvider)
        .create(name: 'BCA', type: AccountType.bank, icon: 'landmark', initialBalance: 6235000);

    final obligations = container.read(obligationRepositoryProvider);
    for (final (name, amount, dueDay, categoryName) in [
      ('Listrik', 350000, 20, 'Tagihan & utilitas'),
      ('Cicilan motor', 850000, 25, 'Cicilan'),
      ('Kos', 1000000, 25, 'Tempat tinggal'),
    ]) {
      await obligations.create(
        name: name,
        amountType: ObligationAmountType.fixed,
        amount: amount,
        dueDay: dueDay,
        categoryId: category(categoryName),
        startsOn: d(2026, 10, 1),
      );
    }
    await obligations.ensureInstances(calculator: PayCycleCalculator(rule), today: today);
    for (final instance in await db.select(db.obligationInstances).get()) {
      if (instance.dueDate.month == 10) {
        await obligations.recordPayment(
          instanceId: instance.id,
          accountId: bca,
          amount: instance.expectedAmount,
          date: instance.dueDate.toLocal(),
        );
      }
    }

    final transactions = container.read(transactionRepositoryProvider);
    for (var day = d(2026, 10, 25); day <= today; day = day.addDays(1)) {
      await transactions.add(
        NewTransaction.expense(
          amount: day < d(2026, 11, 5) ? 40000 : 85000,
          accountId: bca,
          categoryId: food,
          date: day.toDateTime().add(const Duration(hours: 12)),
        ),
      );
    }
    return (bca: bca, food: food);
  }

  test('belum onboarding: belum ada Safe-to-Spend', () async {
    expect(await service.compute(today), isNull);
  });

  test('Lampiran A PRD dihitung dari isi database', () async {
    await seedLampiranA();
    final snapshot = (await service.compute(today))!;

    expect(snapshot.cycle, PayCycle(start: d(2026, 10, 25), nextPayday: d(2026, 11, 25)));
    expect(snapshot.safeToSpend.availableBalance, 3000000);
    expect(snapshot.safeToSpend.obligationsReserved, 2200000);
    expect(snapshot.safeToSpend.buffer, 40000);
    expect(snapshot.safeToSpend.amount, 760000);
    expect(snapshot.safeToSpend.dailyAllowance, 54285);
    expect(snapshot.safeToSpend.daysLeft, 14);

    expect(snapshot.risk.averageDailySpend, 85000);
    expect(snapshot.risk.projectedShortfall, 430000);
    expect(snapshot.risk.level, RiskLevel.danger);

    expect(snapshot.reservedDues.map((due) => due.obligationName), [
      'Listrik',
      'Cicilan motor',
      'Kos',
    ]);
    expect(snapshot.protectedCount, 3);
  });

  test('melewati gajian: siklus baru, kewajiban yang belum dibayar tetap dicadangkan', () async {
    await seedLampiranA();
    final snapshot = (await service.compute(d(2026, 11, 26)))!;

    expect(snapshot.cycle, PayCycle(start: d(2026, 11, 25), nextPayday: d(2026, 12, 25)));
    expect(snapshot.reservedDues.map((due) => due.dueDate.toString()), [
      '2026-11-20',
      '2026-11-25',
      '2026-11-25',
      '2026-12-20',
      '2026-12-25',
      '2026-12-25',
    ]);
    expect(snapshot.safeToSpend.obligationsReserved, 4400000);
  });

  test('buffer mengikuti pengaturan siklus', () async {
    await seedLampiranA();
    await container
        .read(payCycleRepositoryProvider)
        .save(rule: rule, expectedIncome: 7500000, bufferBasisPoints: 0);

    expect((await service.compute(today))!.safeToSpend.amount, 800000);
  });

  group('target tabungan', () {
    Future<int> addSavingsAccount({required bool protected}) => container
        .read(accountRepositoryProvider)
        .create(
          name: 'Tabungan',
          type: AccountType.bank,
          icon: 'piggy-bank',
          includeInSafeToSpend: !protected,
        );

    Future<int> addGoal({int? accountId, int? target, LocalDate? deadline, int? perCycle}) =>
        container.read(savingsRepositoryProvider).create((
          name: 'Laptop',
          targetAmount: target,
          deadline: deadline,
          amountPerCycle: perCycle,
          accountId: accountId,
        ));

    Future<void> deposit(int goal, int amount, {int? from, DateTime? at}) => container
        .read(savingsRepositoryProvider)
        .contribute(
          goalId: goal,
          amount: amount,
          date: at ?? DateTime(2026, 11, 10),
          fromAccountId: from,
        );

    test('setoran ke rekening yang dikecualikan mengurangi sisa target', () async {
      final seeded = await seedLampiranA();
      final savingsAccount = await addSavingsAccount(protected: true);
      final goal = await addGoal(accountId: savingsAccount, perCycle: 500000);

      final before = (await service.compute(today))!.safeToSpend;
      expect(before.savingsReserved, 500000);

      await deposit(goal, 200000, from: seeded.bca);
      final after = (await service.compute(today))!.safeToSpend;
      expect(after.savingsReserved, 300000);
      expect(after.availableBalance, 2800000);
      expect(after.amount, before.amount, reason: 'menabung tidak mengubah Safe-to-Spend');
    });

    test('tanpa rekening: setoran siklus lalu tetap disisihkan dari saldo', () async {
      await seedLampiranA();
      final goal = await addGoal(perCycle: 500000);
      await deposit(goal, 400000, at: DateTime(2026, 10, 10)); // siklus lalu

      final before = (await service.compute(today))!.safeToSpend;
      // 400 rb yang sudah disisihkan + 500 rb setoran siklus ini.
      expect(before.savingsReserved, 900000);
      expect(before.availableBalance, 3000000);

      await deposit(goal, 200000);
      final after = (await service.compute(today))!.safeToSpend;
      expect(after.savingsReserved, 900000);
      expect(after.amount, before.amount, reason: 'menabung tidak mengubah Safe-to-Spend');
    });

    test('bertenggat: kebutuhan per siklus dari sisa target dan siklus tersisa', () async {
      await seedLampiranA();
      final savingsAccount = await addSavingsAccount(protected: true);
      await addGoal(accountId: savingsAccount, target: 6000000, deadline: d(2027, 4, 20));

      // 6 siklus: 25 Okt sampai siklus 25 Mar yang memuat 20 Apr.
      expect((await service.compute(today))!.safeToSpend.savingsReserved, 1000000);
    });

    test('target yang diarsipkan tidak dicadangkan lagi', () async {
      await seedLampiranA();
      final goal = await addGoal(perCycle: 500000);
      await container.read(savingsRepositoryProvider).archive(goal);
      expect((await service.compute(today))!.safeToSpend.savingsReserved, 0);
    });
  });

  group('sisihan gaji', () {
    late int bca;
    late int food;

    /// Gaji Rp 2.000.000 tiap tanggal 25; mulai mencatat 25 Okt dengan saldo
    /// BCA Rp 2.000.000. Sisihan 10% (Rp 200.000) dipasang 26 Okt.
    Future<void> seed() async {
      await container
          .read(payCycleRepositoryProvider)
          .save(rule: rule, expectedIncome: 2000000, trackingSince: d(2026, 10, 25));
      bca = await container
          .read(accountRepositoryProvider)
          .create(name: 'BCA', type: AccountType.bank, icon: 'landmark', initialBalance: 2000000);
      food = (await container.read(categoryRepositoryProvider).active())
          .firstWhere((c) => c.name == 'Makan & minum')
          .id;
      await container.read(salaryShareServiceProvider).setShare(1000, today: d(2026, 10, 26));
    }

    Future<void> spend(int amount, DateTime at) => container
        .read(transactionRepositoryProvider)
        .add(NewTransaction.expense(amount: amount, accountId: bca, categoryId: food, date: at));

    Future<List<int>> saved() async => [
      for (final contribution in await db.select(db.goalContributions).get()) contribution.amount,
    ];

    test('dikunci dari Safe-to-Spend sepanjang siklus berjalan', () async {
      await seed();
      final snapshot = (await service.compute(d(2026, 11, 11)))!.safeToSpend;

      expect(snapshot.savingsReserved, 200000);
      // Dana cadangan tetap ada: 5% × (2.000.000 − 200.000) = 90.000.
      expect(snapshot.buffer, 90000);
      expect(snapshot.amount, 1710000);
    });

    test('saat gajian, sisihan yang tersisa ditabung dan tetap dikunci', () async {
      await seed();
      await spend(1700000, DateTime(2026, 11, 1, 12));
      final snapshot = (await service.compute(d(2026, 11, 25)))!.safeToSpend;

      final contribution = (await db.select(db.goalContributions).get()).single;
      expect(contribution.amount, 200000);
      expect(LocalDate.fromDateTime(contribution.date), d(2026, 11, 24));
      // Saldo 300.000: 200.000 tabungan + 200.000 sisihan siklus baru dikunci.
      expect(snapshot.availableBalance, 300000);
      expect(snapshot.savingsReserved, 400000);

      // Ditabung sekali saja, walau belanja siklus lalu dicatat belakangan.
      await spend(50000, DateTime(2026, 11, 24, 20));
      await service.compute(d(2026, 11, 26));
      expect(await saved(), [200000]);
    });

    test('belanja yang memakai sisihan mengurangi yang ditabung', () async {
      await seed();
      await spend(1900000, DateTime(2026, 11, 1, 12));
      await service.compute(d(2026, 11, 25));
      expect(await saved(), [100000]);
    });

    test('kewajiban yang jatuh tempo di hari gajian didahulukan', () async {
      await seed();
      final obligations = container.read(obligationRepositoryProvider);
      final housing = (await container.read(categoryRepositoryProvider).active())
          .firstWhere((c) => c.name == 'Tempat tinggal')
          .id;
      await obligations.create(
        name: 'Kos',
        amountType: ObligationAmountType.fixed,
        amount: 150000,
        dueDay: 25,
        categoryId: housing,
        startsOn: d(2026, 10, 26),
      );
      await obligations.ensureInstances(
        calculator: PayCycleCalculator(rule),
        today: d(2026, 11, 25),
      );
      await spend(1700000, DateTime(2026, 11, 1, 12));
      // Kos 25 Nov dicadangkan dari siklus yang berakhir 24 Nov, lalu dibayar
      // pagi hari gajian: uangnya belum keluar saat siklus itu berakhir.
      final kos = (await db.select(db.obligationInstances).get()).singleWhere(
        (i) => LocalDate.fromDateTime(i.dueDate) == d(2026, 11, 25),
      );
      await obligations.recordPayment(
        instanceId: kos.id,
        accountId: bca,
        amount: 150000,
        date: DateTime(2026, 11, 25, 9),
      );

      await service.compute(d(2026, 11, 25));
      expect(await saved(), [150000]);
    });

    test('persen 0 menghentikan sisihan; lepas semua menghapus targetnya', () async {
      await seed();
      await spend(1700000, DateTime(2026, 11, 1, 12));
      await service.compute(d(2026, 11, 25));
      final salary = container.read(salaryShareServiceProvider);

      await salary.setShare(0, today: d(2026, 11, 26));
      var snapshot = (await service.compute(d(2026, 11, 26)))!.safeToSpend;
      expect(snapshot.savingsReserved, 200000, reason: 'tabungan yang sudah ada tetap dikunci');

      await salary.release();
      snapshot = (await service.compute(d(2026, 11, 26)))!.safeToSpend;
      expect(snapshot.savingsReserved, 0);
      expect(await db.select(db.savingsGoals).get(), isEmpty);
    });
  });

  test('stream menghitung ulang saat transaksi baru dicatat', () async {
    final seeded = await seedLampiranA();
    final snapshots = StreamIterator(service.watch(() => today));
    addTearDown(snapshots.cancel);

    Future<SafeToSpendSnapshot> next(bool Function(SafeToSpendSnapshot) where) async {
      while (await snapshots.moveNext().timeout(const Duration(seconds: 5))) {
        final snapshot = snapshots.current;
        if (snapshot != null && where(snapshot)) return snapshot;
      }
      throw StateError('stream selesai');
    }

    final first = await next((_) => true);
    expect(first.safeToSpend.amount, 760000);

    await container
        .read(transactionRepositoryProvider)
        .add(
          NewTransaction.expense(
            amount: 100000,
            accountId: seeded.bca,
            categoryId: seeded.food,
            date: DateTime(2026, 11, 11, 19),
          ),
        );
    final updated = await next((s) => s.safeToSpend.amount != 760000);
    expect(updated.safeToSpend.amount, 665000);
  });

  test('provider Riverpod memakai jam dan kalender yang di-override', () async {
    await seedLampiranA();
    final subscription = container.listen(safeToSpendProvider, (_, _) {});
    addTearDown(subscription.close);

    final snapshot = await container.read(safeToSpendProvider.future);
    expect(snapshot!.today, today);
    expect(snapshot.safeToSpend.amount, 760000);
  });
}
