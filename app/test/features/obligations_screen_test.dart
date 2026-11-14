import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/app.dart';
import 'package:keuangan_app/core/model/enums.dart';
import 'package:keuangan_app/core/widgets/day_of_month_grid.dart';
import 'package:keuangan_app/core/widgets/rupiah_field.dart';
import 'package:keuangan_app/data/db/app_database.dart';
import 'package:keuangan_app/data/db/database_provider.dart';
import 'package:keuangan_app/data/providers.dart';
import 'package:keuangan_app/data/repositories/account_repository.dart';
import 'package:keuangan_app/data/repositories/category_repository.dart';
import 'package:keuangan_app/data/repositories/obligation_repository.dart';
import 'package:keuangan_app/data/repositories/pay_cycle_repository.dart';
import 'package:keuangan_app/engine/common/local_date.dart';
import 'package:keuangan_app/engine/cycle/holiday_calendar.dart';
import 'package:keuangan_app/engine/cycle/pay_cycle.dart';
import 'package:keuangan_app/features/obligations/presentation/obligations_screen.dart';
import 'package:keuangan_app/features/onboarding/application/onboarding_controller.dart';
import 'package:keuangan_app/features/onboarding/application/onboarding_draft.dart';

void main() {
  late AppDatabase db;

  /// Onboarding di awal siklus (26 Okt), gajian tanggal 25; hari ini Rab 11 Nov.
  /// Kos 1 Nov sudah dibayar, Internet 9 Nov belum.
  Future<void> setUpData() async {
    db = AppDatabase(NativeDatabase.memory());
    final obligations = ObligationRepository(db);
    await OnboardingService(
      db: db,
      accounts: AccountRepository(db),
      categories: CategoryRepository(db),
      obligations: obligations,
      payCycles: PayCycleRepository(db),
    ).complete(
      const OnboardingDraft(
        shiftOnHoliday: false,
        expectedIncome: 6000000,
        accounts: [AccountDraft(id: 0, name: 'BCA', type: AccountType.bank, balance: 4000000)],
        obligations: [
          ObligationDraft(name: 'Kos', amount: 1000000, dueDay: 1, categoryName: 'Tempat tinggal'),
          ObligationDraft(
            name: 'Internet',
            amount: 300000,
            dueDay: 9,
            categoryName: 'Tagihan & utilitas',
          ),
          ObligationDraft(
            name: 'Listrik',
            amount: 350000,
            dueDay: 20,
            categoryName: 'Tagihan & utilitas',
            amountType: ObligationAmountType.estimated,
          ),
          ObligationDraft(
            name: 'Cicilan motor',
            amount: 850000,
            dueDay: 25,
            categoryName: 'Cicilan',
          ),
        ],
      ),
      today: LocalDate(2026, 10, 26),
    );
    await obligations.ensureInstances(
      calculator: PayCycleCalculator(PayCycleRule.fixedDate(25, shiftOnHoliday: false)),
      today: LocalDate(2026, 11, 11),
    );
    final kos = await (db.select(
      db.obligationInstances,
    )..where((i) => i.dueDate.equals(LocalDate(2026, 11, 1).toUtcMidnight()))).getSingle();
    final bca = (await AccountRepository(db).balances()).single.account.id;
    await obligations.recordPayment(
      instanceId: kos.id,
      accountId: bca,
      amount: 1000000,
      date: DateTime(2026, 11, 1, 9),
    );
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          databaseStatusProvider.overrideWith(
            (ref) async => (cipher: 'test', schemaVersion: 2, categoryCount: 13),
          ),
          clockProvider.overrideWithValue(() => DateTime(2026, 11, 11, 20)),
          holidayCalendarProvider.overrideWithValue(const NoHolidays()),
        ],
        child: const MoneytoringApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: find.byType(NavigationBar), matching: find.text('Kewajiban')),
    );
    await tester.pumpAndSettle();
  }

  Finder inScreen(Finder finder) =>
      find.descendant(of: find.byType(ObligationsScreen), matching: finder);

  Future<void> reveal(WidgetTester tester, Finder target) async {
    if (target.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        target,
        200,
        scrollable: inScreen(find.byType(Scrollable)).first,
      );
    }
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
  }

  // Kartu progres ada di puncak daftar; setelah scroll ke bawah, kembali dulu.
  Future<void> toTop(WidgetTester tester) async {
    await tester.drag(inScreen(find.byType(Scrollable)).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder target) async {
    await reveal(tester, target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> enterAmount(WidgetTester tester, String digits) async {
    await tester.enterText(
      find.descendant(of: find.byType(RupiahField).last, matching: find.byType(TextField)),
      digits,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('progres siklus, tandai lunas, cicilan, tambah dan hapus kewajiban', (tester) async {
    await setUpData();
    await pumpApp(tester);

    // Kartu progres: Kos lunas; sisanya dicadangkan sampai gajian.
    expect(inScreen(find.text('Siklus 25 Okt – 24 Nov')), findsOneWidget);
    expect(find.text('1 dari 4 lunas'), findsOneWidget);
    expect(find.text('Rp 2.500.000 / siklus'), findsOneWidget);
    expect(find.text('Rp 1.500.000'), findsOneWidget); // sisa sampai gajian
    expect(find.text('TERLAMBAT'), findsOneWidget);
    expect(find.text('Jatuh tempo 9 Nov · lewat 2 hari'), findsOneWidget);
    await reveal(tester, find.text('Dibayar 1 Nov · BCA'));
    await toTop(tester);

    // A3 di layar: Internet lewat jatuh tempo tanpa transaksi.
    expect(find.text('Internet sudah dibayar?'), findsOneWidget);
    expect(
      find.text('Lewat 2 hari dari jatuh tempo dan belum ada transaksi yang cocok.'),
      findsOneWidget,
    );
    await tap(tester, find.text('Tandai lunas'));
    expect(find.text('Bayar Internet'), findsOneWidget);
    expect(find.text('300.000'), findsOneWidget);
    await tap(tester, find.text('Simpan pembayaran'));
    expect(find.text('Internet tercatat lunas.'), findsOneWidget);
    await toTop(tester);
    expect(find.text('2 dari 4 lunas'), findsOneWidget);
    expect(find.text('Internet sudah dibayar?'), findsNothing);
    expect(find.text('TERLAMBAT'), findsNothing);

    // Tagihan berubah-ubah lebih kecil dari estimasi: langsung lunas.
    await tap(tester, find.text('±Rp 350.000').first);
    expect(find.text('Bayar Listrik'), findsOneWidget);
    await enterAmount(tester, '312000');
    expect(find.text('Tandai lunas'), findsOneWidget);
    await tap(tester, find.text('Simpan pembayaran'));
    expect(find.text('Listrik tercatat lunas.'), findsOneWidget);
    await toTop(tester);
    expect(find.text('3 dari 4 lunas'), findsOneWidget);

    // Nominal tetap yang dibayar sebagian: dicatat sebagai cicilan.
    await tap(tester, find.text('25 Nov · 14 hari lagi'));
    expect(find.text('Bayar Cicilan motor'), findsOneWidget);
    await enterAmount(tester, '400000');
    await tap(tester, find.text('Simpan pembayaran'));
    expect(
      find.text('Pembayaran Cicilan motor tercatat. Sisa Rp 450.000 tetap dicadangkan.'),
      findsOneWidget,
    );
    await reveal(tester, find.text('Dicicil'));
    await toTop(tester);
    expect(find.text('3 dari 4 lunas'), findsOneWidget);

    // Tambah kewajiban baru: langsung muncul di timeline.
    await tester.tap(find.byTooltip('Tambah kewajiban'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah kewajiban'), findsWidgets);
    await tester.enterText(find.widgetWithText(TextField, 'Nama kewajiban'), 'Netflix');
    await tester.pumpAndSettle();
    await enterAmount(tester, '54000');
    final day15 = find.descendant(of: find.byType(DayOfMonthGrid).last, matching: find.text('15'));
    await tester.ensureVisible(day15);
    await tester.pumpAndSettle();
    await tester.tap(day15);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Simpan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Netflix ditambahkan.'), findsOneWidget);
    expect(find.text('3 dari 5 lunas'), findsOneWidget);
    await reveal(tester, find.text('15 Nov · 4 hari lagi'));

    // Hapus lewat "Semua kewajiban".
    await tap(tester, find.text('Tiap tanggal 15'));
    expect(find.text('Ubah kewajiban'), findsOneWidget);
    await tester.ensureVisible(find.text('Hapus kewajiban'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus kewajiban'));
    await tester.pumpAndSettle();
    expect(find.text('Hapus Netflix?'), findsOneWidget);
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    expect(find.text('Netflix dihapus.'), findsOneWidget);
    expect(find.text('Tiap tanggal 15'), findsNothing);
    await toTop(tester);
    expect(find.text('3 dari 4 lunas'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  });

  // Kategori bisa diarsipkan dari Pengaturan, termasuk "Lainnya" yang menjadi
  // kategori bawaan kewajiban baru.
  testWidgets('kewajiban baru tetap tersimpan walau kategori Lainnya diarsipkan', (tester) async {
    await setUpData();
    final categories = CategoryRepository(db);
    final expense = await categories.active(type: CategoryType.expense);
    await categories.archive(expense.singleWhere((c) => c.name == 'Lainnya').id);
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Tambah kewajiban'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Nama kewajiban'), 'Netflix');
    await tester.pumpAndSettle();
    await enterAmount(tester, '54000');
    await tester.ensureVisible(find.text('Simpan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Netflix ditambahkan.'), findsOneWidget);
    final netflix = await (db.select(
      db.obligations,
    )..where((o) => o.name.equals('Netflix'))).getSingle();
    expect(netflix.categoryId, expense.first.id);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  });
}
