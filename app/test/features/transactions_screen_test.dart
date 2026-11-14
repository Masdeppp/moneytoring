import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/app.dart';
import 'package:keuangan_app/core/model/enums.dart';
import 'package:keuangan_app/data/db/app_database.dart';
import 'package:keuangan_app/data/db/database_provider.dart';
import 'package:keuangan_app/data/providers.dart';
import 'package:keuangan_app/data/repositories/account_repository.dart';
import 'package:keuangan_app/data/repositories/category_repository.dart';
import 'package:keuangan_app/data/repositories/obligation_repository.dart';
import 'package:keuangan_app/data/repositories/pay_cycle_repository.dart';
import 'package:keuangan_app/data/repositories/transaction_repository.dart';
import 'package:keuangan_app/engine/common/local_date.dart';
import 'package:keuangan_app/engine/cycle/holiday_calendar.dart';
import 'package:keuangan_app/features/onboarding/application/onboarding_controller.dart';
import 'package:keuangan_app/features/onboarding/application/onboarding_draft.dart';
import 'package:keuangan_app/features/transactions/presentation/transactions_screen.dart';

void main() {
  late AppDatabase db;
  late int bca;
  late int gopay;
  late Map<String, int> categoryIds;

  /// Pengguna dengan BCA dan GoPay, gajian tanggal 25, hari ini Rab 11 Nov 2026.
  Future<void> onboard() async {
    db = AppDatabase(NativeDatabase.memory());
    await OnboardingService(
      db: db,
      accounts: AccountRepository(db),
      categories: CategoryRepository(db),
      obligations: ObligationRepository(db),
      payCycles: PayCycleRepository(db),
    ).complete(
      const OnboardingDraft(
        shiftOnHoliday: false,
        expectedIncome: 6000000,
        accounts: [
          AccountDraft(id: 0, name: 'BCA', type: AccountType.bank, balance: 3000000),
          AccountDraft(id: 1, name: 'GoPay', type: AccountType.ewallet, balance: 200000),
        ],
      ),
      today: LocalDate(2026, 11, 11),
    );
    final accounts = await AccountRepository(db).balances();
    bca = accounts.firstWhere((a) => a.account.name == 'BCA').account.id;
    gopay = accounts.firstWhere((a) => a.account.name == 'GoPay').account.id;
    categoryIds = {for (final c in await CategoryRepository(db).active()) c.name: c.id};
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
      find.descendant(of: find.byType(NavigationBar), matching: find.text('Transaksi')),
    );
    await tester.pumpAndSettle();
  }

  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  }

  Finder chip(String label) => find.widgetWithText(FilterChip, label);
  bool selected(WidgetTester tester, String label) =>
      tester.widget<FilterChip>(chip(label)).selected;

  // Baris chip di-scroll menyamping; chip di kanan harus digeser masuk dulu.
  Future<void> tapChip(WidgetTester tester, String label) async {
    await tester.ensureVisible(chip(label));
    await tester.pumpAndSettle();
    await tester.tap(chip(label));
    await tester.pumpAndSettle();
  }

  testWidgets('ringkasan siklus, grup per hari, filter, pencarian, lalu hapus', (tester) async {
    await onboard();
    final repo = TransactionRepository(db);
    await repo.add(
      NewTransaction.income(
        amount: 6000000,
        accountId: bca,
        categoryId: categoryIds['Gaji']!,
        date: DateTime(2026, 10, 25, 9),
      ),
    );
    await repo.add(
      NewTransaction.expense(
        amount: 25000,
        accountId: gopay,
        categoryId: categoryIds['Makan & minum']!,
        date: DateTime(2026, 11, 11, 12),
        note: 'Makan siang',
      ),
    );
    await repo.add(
      NewTransaction.expense(
        amount: 18000,
        accountId: gopay,
        categoryId: categoryIds['Transportasi']!,
        date: DateTime(2026, 11, 11, 8),
        note: 'Ojek ke kantor',
      ),
    );
    await repo.add(
      NewTransaction.expense(
        amount: 12000,
        accountId: bca,
        categoryId: categoryIds['Makan & minum']!,
        date: DateTime(2026, 11, 10, 15),
        note: 'Kopi susu',
      ),
    );
    await repo.add(
      NewTransaction.transfer(
        amount: 100000,
        fromAccountId: bca,
        toAccountId: gopay,
        date: DateTime(2026, 11, 10, 9),
      ),
    );
    await pumpApp(tester);

    // Ringkasan siklus: transfer tidak dihitung.
    expect(find.text('Siklus 25 Okt – 24 Nov'), findsOneWidget);
    expect(find.text('Rp 55.000'), findsOneWidget);
    expect(find.text('+Rp 6.000.000'), findsWidgets);

    // Grup per hari dengan total bersih.
    expect(find.text('HARI INI · RAB, 11 NOV'), findsOneWidget);
    expect(find.text('−Rp 43.000'), findsOneWidget);
    expect(find.text('KEMARIN · SEL, 10 NOV'), findsOneWidget);
    expect(find.text('−Rp 12.000'), findsNWidgets(2)); // total hari + baris kopi
    expect(find.text('BCA → GoPay'), findsOneWidget);
    expect(selected(tester, 'Semua'), isTrue);

    // Jenis: hanya pemasukan; ketuk lagi untuk melepas.
    await tapChip(tester, 'Pemasukan');
    expect(find.text('Makan siang'), findsNothing);
    expect(find.text('Gaji'), findsOneWidget);
    expect(selected(tester, 'Semua'), isFalse);
    await tapChip(tester, 'Pemasukan');
    expect(find.text('Makan siang'), findsOneWidget);

    // Akun: GoPay, termasuk transfer masuk ke GoPay.
    await tapChip(tester, 'GoPay');
    expect(find.text('Ojek ke kantor'), findsOneWidget);
    expect(find.text('BCA → GoPay'), findsOneWidget);
    expect(find.text('Kopi susu'), findsNothing);
    await tapChip(tester, 'GoPay');

    // Kategori lewat sheet; jenisnya ikut terpilih.
    await tapChip(tester, 'Kategori');
    expect(find.text('Pilih kategori'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Transportasi'));
    await tester.pumpAndSettle();
    expect(find.text('Ojek ke kantor'), findsOneWidget);
    expect(find.text('Makan siang'), findsNothing);
    expect(selected(tester, 'Transportasi'), isTrue);
    expect(selected(tester, 'Pengeluaran'), isTrue);

    // Pindah ke Transfer melepas kategori; "Semua" melepas semuanya.
    await tapChip(tester, 'Transfer');
    expect(chip('Kategori'), findsOneWidget);
    expect(find.text('BCA → GoPay'), findsOneWidget);
    expect(find.text('Ojek ke kantor'), findsNothing);
    await tapChip(tester, 'Semua');
    expect(find.text('Ojek ke kantor'), findsOneWidget);

    // Pencarian (debounce 250 ms), lalu hasil kosong dan "Hapus filter".
    await tester.tap(find.byTooltip('Cari transaksi'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'kopi');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Kopi susu'), findsOneWidget);
    expect(find.text('Makan siang'), findsNothing);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Tidak ada transaksi yang cocok.'), findsOneWidget);
    await tester.tap(find.text('Hapus filter'));
    await tester.pumpAndSettle();
    expect(find.text('Makan siang'), findsOneWidget);
    await tester.tap(find.byTooltip('Tutup pencarian'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);

    // Ketuk transaksi untuk mengubah/hapus; ringkasan ikut berubah.
    await tester.tap(find.text('Kopi susu'));
    await tester.pumpAndSettle();
    expect(find.text('Rp 12.000'), findsOneWidget);
    await tester.tap(find.text('Hapus transaksi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    expect(find.text('Kopi susu'), findsNothing);
    expect(find.text('Rp 43.000'), findsOneWidget);

    await closeApp(tester);
  });

  testWidgets('belum ada transaksi', (tester) async {
    await onboard();
    await pumpApp(tester);
    expect(find.text('Belum ada transaksi. Ketuk + untuk mencatat yang pertama.'), findsOneWidget);
    expect(find.text('Rp 0'), findsNWidgets(2));
    await closeApp(tester);
  });

  testWidgets('halaman berikutnya dimuat saat di-scroll ke bawah', (tester) async {
    await onboard();
    // Satu lebih banyak dari satu halaman, semuanya di hari yang sama.
    const count = TransactionsScreen.pageSize + 1;
    await db.batch(
      (batch) => batch.insertAll(db.transactions, [
        for (var i = 0; i < count; i++)
          NewTransaction.expense(
            amount: 1000,
            accountId: bca,
            categoryId: categoryIds['Makan & minum']!,
            date: DateTime(2026, 11, 11, 7).add(Duration(minutes: i)),
            note: 'Jajan $i',
          ).toCompanion(),
      ]),
    );
    await pumpApp(tester);

    // Halaman pertama terpotong di hari ini, jadi total harinya belum tampil.
    expect(find.text('HARI INI · RAB, 11 NOV'), findsOneWidget);
    expect(find.text('−Rp 101.000'), findsNothing);
    expect(find.text('Jajan 1'), findsOneWidget);
    expect(find.text('Jajan 0'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Jajan 0'),
      600,
      scrollable: find
          .descendant(of: find.byType(TransactionsScreen), matching: find.byType(Scrollable))
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Jajan 0'), findsOneWidget);
    expect(find.text('−Rp 101.000'), findsOneWidget);

    await closeApp(tester);
  });
}
