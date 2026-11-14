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
import 'package:keuangan_app/engine/common/local_date.dart';
import 'package:keuangan_app/engine/cycle/holiday_calendar.dart';
import 'package:keuangan_app/features/onboarding/application/onboarding_controller.dart';
import 'package:keuangan_app/features/onboarding/application/onboarding_draft.dart';

void main() {
  testWidgets('catat pengeluaran dari FAB, lalu ubah dan hapus dari Beranda', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // Lampiran A PRD lewat onboarding: saldo 3 jt, kewajiban 2,2 jt sebelum gajian.
    final db = AppDatabase(NativeDatabase.memory());
    await OnboardingService(
      db: db,
      accounts: AccountRepository(db),
      categories: CategoryRepository(db),
      obligations: ObligationRepository(db),
      payCycles: PayCycleRepository(db),
    ).complete(
      const OnboardingDraft(
        shiftOnHoliday: false,
        expectedIncome: 7500000,
        accounts: [AccountDraft(id: 0, name: 'BCA', type: AccountType.bank, balance: 3000000)],
        obligations: [
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
          ObligationDraft(name: 'Kos', amount: 1000000, dueDay: 25, categoryName: 'Tempat tinggal'),
        ],
      ),
      today: LocalDate(2026, 11, 11),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          databaseStatusProvider.overrideWith(
            (ref) async => (cipher: 'test', schemaVersion: 2, categoryCount: 13),
          ),
          clockProvider.overrideWithValue(() => DateTime(2026, 11, 11, 10)),
          holidayCalendarProvider.overrideWithValue(const NoHolidays()),
        ],
        child: const MoneytoringApp(),
      ),
    );
    await tester.pumpAndSettle();

    // [up]: elemen ada di atas posisi scroll sekarang (mis. kartu di puncak Beranda).
    Future<void> reveal(Finder target, {bool up = false}) async {
      if (target.evaluate().isEmpty) {
        await tester.scrollUntilVisible(
          target,
          up ? -150 : 150,
          scrollable: find.byType(Scrollable).first,
        );
      }
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
    }

    Future<void> tap(Finder target) async {
      await reveal(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    // Beranda: kartu dan kewajiban terdekat dari data asli.
    expect(find.text('Rp 760.000'), findsOneWidget);
    expect(find.text('Kewajiban terdekat'), findsOneWidget);
    expect(find.text('20 Nov · 9 hari lagi'), findsOneWidget);
    expect(find.text('±Rp 350.000'), findsOneWidget);
    await reveal(find.text('Belum ada transaksi. Ketuk + untuk mencatat yang pertama.'));

    // Quick Add: FAB → keypad → Simpan. Kategori dan akun sudah terisi.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Aman dibelanjakan Rp 760.000'), findsOneWidget);
    for (final key in ['2', '5', '000']) {
      await tester.tap(find.text(key).last);
      await tester.pump();
    }
    expect(find.text('Rp 25.000'), findsOneWidget);
    // (3.000.000 − 25.000 − 2.200.000) − buffer 5% = 736.250
    expect(find.text('Sisa aman setelah ini Rp 736.250'), findsOneWidget);
    await tap(find.text('Simpan'));

    expect(find.text('Aman dibelanjakan kini Rp 736.250'), findsOneWidget);
    await reveal(find.text('Rp 736.250'), up: true);
    expect(find.text('Rp 736.250'), findsOneWidget);
    final row = find.text('−Rp 25.000');
    await reveal(row);
    expect(find.text('Makan & minum'), findsOneWidget);

    // Ubah: buka transaksi dari Beranda; tanpa perubahan nominal, Safe-to-Spend tetap.
    await tap(row);
    expect(find.text('Rp 25.000'), findsOneWidget);
    expect(find.text('Tidak mengubah Safe-to-Spend'), findsOneWidget);
    await tap(find.text('Hapus transaksi'));
    await tap(find.text('Hapus'));

    expect(find.text('Transaksi dihapus · Aman dibelanjakan kini Rp 760.000'), findsOneWidget);
    expect(find.text('−Rp 25.000'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  });
}
