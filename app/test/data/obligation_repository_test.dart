import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/model/enums.dart';
import 'package:keuangan_app/data/db/app_database.dart';
import 'package:keuangan_app/data/repositories/account_repository.dart';
import 'package:keuangan_app/data/repositories/category_repository.dart';
import 'package:keuangan_app/data/repositories/obligation_repository.dart';
import 'package:keuangan_app/data/repositories/transaction_repository.dart';
import 'package:keuangan_app/engine/common/local_date.dart';
import 'package:keuangan_app/engine/cycle/pay_cycle.dart';

LocalDate d(int y, int m, int day) => LocalDate(y, m, day);

void main() {
  late AppDatabase db;
  late ObligationRepository obligations;
  late TransactionRepository transactions;
  late int bca;
  late int billsId;

  // Skenario PRD: gajian tanggal 25 tanpa geser, hari ini 11 Nov 2026,
  // siklus 25 Okt – 24 Nov, siklus sebelumnya 25 Sep – 24 Okt.
  final calculator = PayCycleCalculator(PayCycleRule.fixedDate(25, shiftOnHoliday: false));
  final today = d(2026, 11, 11);
  final nextPayday = d(2026, 11, 25);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    obligations = ObligationRepository(db);
    transactions = TransactionRepository(db);
    bca = await AccountRepository(db)
        .create(name: 'BCA', type: AccountType.bank, icon: 'landmark', initialBalance: 5000000);
    billsId = (await CategoryRepository(
      db,
    ).active()).firstWhere((c) => c.name == 'Tagihan & utilitas').id;
  });
  tearDown(() => db.close());

  Future<int> create(
    String name,
    int amount,
    int dueDay, {
    LocalDate? startsOn,
    ObligationAmountType amountType = ObligationAmountType.fixed,
  }) => obligations.create(
    name: name,
    amountType: amountType,
    amount: amount,
    dueDay: dueDay,
    categoryId: billsId,
    accountId: bca,
    startsOn: startsOn ?? d(2026, 10, 1),
  );

  Future<List<String>> instanceDates() async => [
    for (final i in await (db.select(
      db.obligationInstances,
    )..orderBy([(i) => OrderingTerm(expression: i.dueDate)])).get())
      LocalDate.fromDateTime(i.dueDate).toString(),
  ];

  test('validasi saat membuat kewajiban', () {
    expect(() => create(' ', 100000, 1), throwsArgumentError);
    expect(() => create('Kos', 0, 1), throwsArgumentError);
    expect(() => create('Kos', 100000, 32), throwsRangeError);
  });

  group('ensureInstances', () {
    test('membuat jatuh tempo siklus sebelumnya dan berjalan, sekali saja', () async {
      await create('Kos', 1000000, 1);

      expect(await obligations.ensureInstances(calculator: calculator, today: today), 2);
      expect(await instanceDates(), ['2026-10-01', '2026-11-01']);
      expect(await obligations.ensureInstances(calculator: calculator, today: today), 0);
    });

    test('jatuh tempo sebelum kewajiban dicatat tidak dibuat', () async {
      await create('Netflix', 54000, 1, startsOn: today);
      await create('Listrik', 350000, 20, startsOn: today);

      await obligations.ensureInstances(calculator: calculator, today: today);
      expect(await instanceDates(), ['2026-11-20']);
    });

    test('kewajiban yang jatuh di hari gajian ikut siklus berjalan', () async {
      await create('Cicilan motor', 850000, 25, startsOn: d(2026, 10, 26));

      await obligations.ensureInstances(calculator: calculator, today: today);
      expect(await instanceDates(), ['2026-11-25']);
    });

    test('kewajiban nonaktif tidak dibuatkan jatuh tempo', () async {
      final id = await create('Gym', 300000, 5);
      await obligations.setActive(id, active: false);

      expect(await obligations.ensureInstances(calculator: calculator, today: today), 0);
      expect(await obligations.watchActive().first, isEmpty);
    });
  });

  group('jatuh tempo dan pembayaran', () {
    late int kosId;
    late int listrikId;

    setUp(() async {
      kosId = await create('Kos', 1000000, 1, startsOn: d(2026, 10, 26));
      listrikId = await create(
        'Listrik',
        350000,
        20,
        startsOn: d(2026, 10, 26),
        amountType: ObligationAmountType.estimated,
      );
      await obligations.ensureInstances(calculator: calculator, today: today);
    });

    Future<ObligationDueView> dueOf(int obligationId) async =>
        (await obligations.unpaidThrough(nextPayday))
            .firstWhere((due) => due.instance.obligationId == obligationId);

    test('yang belum dibayar, termasuk yang lewat, ikut dicadangkan', () async {
      final dues = await obligations.unpaidThrough(nextPayday);

      expect(dues.map((due) => due.obligationName), ['Kos', 'Listrik']);
      expect(dues.first.dueDate, d(2026, 11, 1)); // sudah lewat
      expect(dues.last.amountType, ObligationAmountType.estimated);
      expect(dues.map((due) => due.remaining), [1000000, 350000]);
      expect(dues.first.categoryId, billsId);
      expect(dues.first.accountId, bca);
    });

    test('pembayaran dicicil; lunas otomatis saat nominal tertutup', () async {
      final kos = await dueOf(kosId);
      final txId = await obligations.recordPayment(
        instanceId: kos.instanceId,
        accountId: bca,
        amount: 400000,
        date: DateTime(2026, 11, 1, 9),
      );

      final partial = await dueOf(kosId);
      expect(partial.paidAmount, 400000);
      expect(partial.remaining, 600000);
      expect(partial.status, ObligationStatus.pending);

      final tx = await (db.select(db.transactions)..where((t) => t.id.equals(txId))).getSingle();
      expect(tx.note, 'Kos');
      expect(tx.categoryId, billsId);
      expect(tx.obligationInstanceId, kos.instanceId);

      await obligations.recordPayment(
        instanceId: kos.instanceId,
        accountId: bca,
        amount: 600000,
        date: DateTime(2026, 11, 2),
        note: 'pelunasan',
      );
      expect((await obligations.unpaidThrough(nextPayday)).map((due) => due.obligationName), [
        'Listrik',
      ]);
    });

    test('tandai lunas walau tagihan lebih kecil dari estimasi', () async {
      final listrik = await dueOf(listrikId);
      await obligations.recordPayment(
        instanceId: listrik.instanceId,
        accountId: bca,
        amount: 312000,
        date: DateTime(2026, 11, 18),
        markPaid: true,
      );

      final all = await obligations.watchBetween(d(2026, 11, 1), nextPayday).first;
      final paid = all.firstWhere((due) => due.instance.obligationId == listrikId);
      expect(paid.status, ObligationStatus.paid);
      expect(paid.paidAmount, 312000);
      expect(paid.remaining, 0);
    });

    test('menghapus pembayaran membuat jatuh tempo kembali belum lunas', () async {
      final kos = await dueOf(kosId);
      final txId = await obligations.recordPayment(
        instanceId: kos.instanceId,
        accountId: bca,
        amount: 1000000,
        date: DateTime(2026, 11, 1),
      );
      expect(await obligations.unpaidThrough(nextPayday), hasLength(1));

      await transactions.delete(txId);
      final again = await dueOf(kosId);
      expect(again.status, ObligationStatus.pending);
      expect(again.paidAmount, 0);
    });

    test('jatuh tempo yang dilewati tidak dicadangkan dan statusnya tetap', () async {
      final kos = await dueOf(kosId);
      await obligations.skip(kos.instanceId);
      expect((await obligations.unpaidThrough(nextPayday)).map((due) => due.obligationName), [
        'Listrik',
      ]);

      await refreshObligationStatus(db, kos.instanceId, forcePaid: true);
      final skipped = await (db.select(
        db.obligationInstances,
      )..where((i) => i.id.equals(kos.instanceId))).getSingle();
      expect(skipped.status, ObligationStatus.skipped);
    });

    test('pembayaran nol ditolak; instance yang tidak ada diabaikan', () async {
      final kos = await dueOf(kosId);
      expect(
        () => obligations.recordPayment(
          instanceId: kos.instanceId,
          accountId: bca,
          amount: 0,
          date: DateTime(2026, 11, 1),
        ),
        throwsArgumentError,
      );
      await refreshObligationStatus(db, 9999);
    });

    test('menghapus kewajiban ikut menghapus jatuh temponya', () async {
      await obligations.delete(kosId);
      expect((await obligations.unpaidThrough(nextPayday)).map((due) => due.obligationName), [
        'Listrik',
      ]);
    });
  });
}
