import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/app.dart';
import 'package:keuangan_app/core/model/enums.dart';
import 'package:keuangan_app/core/theme/app_icons.dart';
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
import 'package:keuangan_app/features/onboarding/application/onboarding_controller.dart';
import 'package:keuangan_app/features/onboarding/application/onboarding_draft.dart';
import 'package:keuangan_app/features/settings/presentation/pay_cycle_sheet.dart';

void main() {
  late AppDatabase db;

  /// Onboarding di awal siklus (26 Okt), gajian tanggal 25; hari ini Rab 11 Nov.
  /// BCA Rp 4.000.000, lalu Kos Rp 1.000.000 dibayar 1 Nov: saldo Rp 3.000.000.
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

  /// Membuka aplikasi lalu Pengaturan lewat ikon roda gigi di Beranda.
  Future<void> pumpSettings(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          databaseStatusProvider.overrideWith(
            (ref) async => (cipher: 'test', schemaVersion: 3, categoryCount: 13),
          ),
          clockProvider.overrideWithValue(() => DateTime(2026, 11, 11, 20)),
          holidayCalendarProvider.overrideWithValue(const NoHolidays()),
        ],
        child: const MoneytoringApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Pengaturan'));
    await tester.pumpAndSettle();
    expect(find.text('Pengaturan'), findsOneWidget);
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  }

  /// Daftar layar dibangun malas; gulir dulu kalau barisnya belum ada. Isi
  /// sheet selalu terbangun, jadi cukup dibawa ke area yang terlihat.
  Future<void> reveal(WidgetTester tester, Finder target) async {
    if (target.evaluate().isEmpty) {
      await tester.scrollUntilVisible(target, 200, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder target) async {
    await reveal(tester, target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> enterText(WidgetTester tester, Finder field, String text) async {
    await tester.enterText(field, text);
    await tester.pumpAndSettle();
  }

  /// Isian nominal satu-satunya (atau yang terakhir) di sheet yang terbuka.
  Future<void> enterAmount(WidgetTester tester, String digits) => enterText(
    tester,
    find.descendant(of: find.byType(RupiahField).last, matching: find.byType(TextField)),
    digits,
  );

  Finder amountField(String key) =>
      find.descendant(of: find.byKey(ValueKey(key)), matching: find.byType(TextField));

  bool saveEnabled(WidgetTester tester) =>
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Simpan')).onPressed != null;

  test('formatBasisPoints menulis persen dengan koma desimal', () {
    expect(formatBasisPoints(500), '5%');
    expect(formatBasisPoints(1000), '10%');
    expect(formatBasisPoints(750), '7,5%');
    expect(formatBasisPoints(725), '7,25%');
    expect(formatBasisPoints(705), '7,05%');
  });

  testWidgets('siklus gajian: tanggal, aturan, dan dana cadangan diubah', (tester) async {
    await setUpData();
    await pumpSettings(tester);

    expect(find.text('Gajian tiap tanggal 25'), findsOneWidget);
    expect(find.text('Berikutnya Rab, 25 Nov · 14 hari lagi'), findsOneWidget);
    expect(find.text('Rp 6.000.000'), findsOneWidget);
    expect(find.text('Dana cadangan 5%'), findsOneWidget);

    // Tanggal 28 dan dana cadangan 10%; pratinjau mengikuti sebelum disimpan.
    await tap(tester, find.text('Gajian tiap tanggal 25'));
    expect(find.text('Siklus gajian'), findsOneWidget);
    await tap(tester, find.descendant(of: find.byType(DayOfMonthGrid), matching: find.text('28')));
    expect(find.text('Gajian berikutnya Sab, 28 Nov · 17 hari lagi'), findsOneWidget);
    await tap(
      tester,
      find.descendant(
        of: find.byKey(const ValueKey('buffer')),
        matching: find.widgetWithText(ChoiceChip, '10%'),
      ),
    );
    await tap(tester, find.text('Simpan'));

    expect(find.text('Siklus gajian disimpan.'), findsOneWidget);
    expect(find.text('Gajian tiap tanggal 28'), findsOneWidget);
    expect(find.text('Berikutnya Sab, 28 Nov · 17 hari lagi'), findsOneWidget);
    expect(find.text('Dana cadangan 10%'), findsOneWidget);

    // Hari kerja terakhir: 30 Nov 2026 jatuh di hari Senin.
    await tap(tester, find.text('Perkiraan gaji'));
    await tap(tester, find.widgetWithText(ChoiceChip, 'Hari kerja terakhir'));
    expect(find.byType(DayOfMonthGrid), findsNothing);
    await enterAmount(tester, '6500000');
    await tap(tester, find.text('Simpan'));

    expect(find.text('Gajian di hari kerja terakhir'), findsOneWidget);
    expect(find.text('Berikutnya Sen, 30 Nov · 19 hari lagi'), findsOneWidget);
    expect(find.text('Rp 6.500.000'), findsOneWidget);

    final config = (await PayCycleRepository(db).current())!;
    expect(config.paydayRule, PaydayRule.lastWorkday);
    expect(config.expectedIncome, 6500000);
    expect(config.bufferBasisPoints, 1000);

    await close(tester);
  });

  testWidgets('sisihkan dari gaji: Sisa gaji muncul, lalu dihentikan lagi', (tester) async {
    await setUpData();
    await pumpSettings(tester);

    Finder shareChip(String label) => find.descendant(
      of: find.byKey(const ValueKey('salaryShare')),
      matching: find.widgetWithText(ChoiceChip, label),
    );

    await tap(tester, find.text('Perkiraan gaji'));
    expect(find.text('Semua gaji boleh dipakai sampai gajian berikutnya.'), findsOneWidget);
    await tap(tester, shareChip('10%'));
    expect(
      find.text(
        'Rp 600.000 per siklus dikunci dari Safe-to-Spend. Yang tersisa saat gajian otomatis '
        'ditabung ke "Sisa gaji".',
      ),
      findsOneWidget,
    );
    await tap(tester, find.text('Simpan'));

    expect(find.text('Sisihkan 10% · Dana cadangan 5%'), findsOneWidget);
    await reveal(tester, find.text('Sisihkan 10% gaji · Rp 600.000 siklus ini'));
    expect((await db.select(db.savingsGoals).get()).single.salaryBasisPoints, 1000);

    await tap(tester, find.text('Sisa gaji'));
    expect(find.text('10% dari perkiraan gaji · Rp 600.000 per siklus'), findsOneWidget);
    expect(find.text('Dikunci sampai gajian 25 Nov'), findsOneWidget);
    expect(find.text('Lepas semua'), findsNothing, reason: 'belum ada yang ditabung');

    // Ubah persen membuka sheet Siklus gajian dengan 10% terpilih.
    await tap(tester, find.text('Ubah persen'));
    expect(find.text('Siklus gajian'), findsOneWidget);
    expect(tester.widget<ChoiceChip>(shareChip('10%')).selected, isTrue);
    await tap(tester, shareChip('Tanpa'));
    await tap(tester, find.text('Simpan'));

    // Belum ada tabungannya, jadi targetnya ikut hilang.
    expect(find.text('Sisa gaji'), findsNothing);
    expect(find.text('Dana cadangan 5%'), findsOneWidget);
    expect(await db.select(db.savingsGoals).get(), isEmpty);

    await close(tester);
  });

  testWidgets('akun: tambah, sesuaikan saldo tanpa transaksi, arsipkan', (tester) async {
    await setUpData();
    await pumpSettings(tester);

    expect(find.text('Rekening bank'), findsOneWidget);
    expect(find.text('Rp 3.000.000'), findsOneWidget);

    // Rekening tabungan di luar Safe-to-Spend.
    await tester.tap(find.byTooltip('Tambah akun'));
    await tester.pumpAndSettle();
    expect(find.text('Akun baru'), findsOneWidget);
    expect(saveEnabled(tester), isFalse);
    await enterText(tester, find.widgetWithText(TextField, 'Nama akun'), 'Tabungan');
    await enterAmount(tester, '2000000');
    await tap(tester, find.byType(Switch));
    await tap(tester, find.text('Simpan'));

    expect(find.text('Tabungan ditambahkan.'), findsOneWidget);
    expect(find.text('Rekening bank · tidak dihitung'), findsOneWidget);
    expect(find.text('Rp 2.000.000'), findsOneWidget);

    // Sesuaikan saldo BCA dan ganti jenisnya.
    await tap(tester, find.text('BCA'));
    expect(find.text('Ubah akun'), findsOneWidget);
    expect(find.textContaining('Berbeda dengan saldo sebenarnya?'), findsOneWidget);
    await enterAmount(tester, '3250000');
    expect(
      find.text(
        'Saldo disesuaikan +Rp 250.000 dari Rp 3.000.000, tanpa dicatat sebagai transaksi.',
      ),
      findsOneWidget,
    );
    await tap(tester, find.widgetWithText(ChoiceChip, 'E-wallet'));
    await tap(tester, find.text('Simpan'));

    expect(find.text('Perubahan BCA disimpan.'), findsOneWidget);
    expect(find.text('Rp 3.250.000'), findsOneWidget);
    expect(find.text('E-wallet'), findsOneWidget);

    final bca = (await AccountRepository(db).balances()).first.account;
    expect(bca.type, AccountType.ewallet);
    expect(bca.icon, 'wallet');
    expect(bca.initialBalance, 4250000);
    // Hanya pembayaran Kos; penyesuaian saldo tidak membuat transaksi.
    expect(await db.select(db.transactions).get(), hasLength(1));

    // Arsipkan Tabungan: dialognya menyebut saldo yang tidak lagi dihitung.
    await tap(tester, find.text('Tabungan'));
    await tap(tester, find.text('Arsipkan akun'));
    expect(find.text('Arsipkan Tabungan?'), findsOneWidget);
    expect(
      find.textContaining('Saldo Rp 2.000.000 di akun ini tidak lagi dihitung'),
      findsOneWidget,
    );
    await tester.tap(find.text('Arsipkan'));
    await tester.pumpAndSettle();

    expect(find.text('Tabungan diarsipkan.'), findsOneWidget);
    expect(find.text('Tabungan'), findsNothing);

    // Akun aktif terakhir tidak bisa diarsipkan.
    await tap(tester, find.text('BCA'));
    expect(find.text('Arsipkan akun'), findsNothing);
    expect(find.text('Akun terakhir tidak bisa diarsipkan.'), findsOneWidget);

    await close(tester);
  });

  testWidgets('target rutin: tambah, setor, hapus setoran, tandai selesai', (tester) async {
    await setUpData();
    await pumpSettings(tester);

    expect(find.textContaining('Belum ada target'), findsOneWidget);
    await tap(tester, find.text('Tambah target'));
    expect(find.text('Target tabungan baru'), findsOneWidget);
    await enterText(tester, find.widgetWithText(TextField, 'Nama target'), 'Dana darurat');
    expect(saveEnabled(tester), isFalse);
    await enterText(tester, amountField('perCycle'), '500000');
    await tap(tester, find.text('Simpan'));

    expect(find.text('Target Dana darurat ditambahkan.'), findsOneWidget);
    expect(find.text('Sisihkan Rp 500.000 lagi siklus ini'), findsOneWidget);
    expect(find.textContaining('Belum ada target'), findsNothing);

    // Setor: nominalnya sudah terisi kekurangan siklus ini.
    await tap(tester, find.text('Dana darurat'));
    expect(find.text('Rp 500.000 per siklus'), findsOneWidget);
    expect(find.text('Rp 0 dari Rp 500.000'), findsOneWidget);
    expect(find.text('Riwayat setoran'), findsNothing);
    await tap(tester, find.widgetWithText(FilledButton, 'Setor'));

    expect(find.text('Setoran Rp 500.000 ke Dana darurat dicatat.'), findsOneWidget);
    expect(find.text('Setoran siklus ini terpenuhi'), findsOneWidget);
    // Tanpa rekening tujuan uangnya tidak berpindah.
    expect(find.text('Rp 3.000.000'), findsOneWidget);

    // Hapus setoran dari riwayat.
    await tap(tester, find.text('Dana darurat'));
    expect(find.text('Riwayat setoran'), findsOneWidget);
    expect(find.text('11 Nov 2026'), findsOneWidget);
    expect(find.text('Rp 500.000 dari Rp 500.000'), findsOneWidget);
    await tap(tester, find.byTooltip('Hapus setoran'));
    expect(find.text('Hapus setoran Rp 500.000?'), findsOneWidget);
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    expect(find.text('Riwayat setoran'), findsNothing);
    expect(find.text('Rp 0 dari Rp 500.000'), findsOneWidget);

    // Tandai selesai: target hilang dari daftar, barisnya tetap ada di DB.
    await tap(tester, find.text('Tandai selesai'));
    expect(find.text('Tandai Dana darurat selesai?'), findsOneWidget);
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();

    expect(find.text('Dana darurat ditandai selesai.'), findsOneWidget);
    expect(find.textContaining('Belum ada target'), findsOneWidget);
    expect((await db.select(db.savingsGoals).get()).single.archived, isTrue);

    await close(tester);
  });

  testWidgets('target bertenggat dengan rekening tujuan: setoran menjadi transfer', (tester) async {
    await setUpData();
    await AccountRepository(db).create(
      name: 'Tabungan',
      type: AccountType.bank,
      icon: 'landmark',
      includeInSafeToSpend: false,
    );
    await pumpSettings(tester);

    await tap(tester, find.text('Tambah target'));
    await enterText(tester, find.widgetWithText(TextField, 'Nama target'), 'Liburan');
    await tap(tester, find.widgetWithText(ChoiceChip, 'Sampai tenggat'));
    await enterText(tester, amountField('target'), '3000000');
    expect(saveEnabled(tester), isFalse);

    // Pemilih tanggal dibuka di 180 hari dari hari ini; terima apa adanya.
    await tap(tester, find.text('Pilih tenggat'));
    await tester.tap(
      find.descendant(of: find.byType(DatePickerDialog), matching: find.byType(TextButton)).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('Tenggat 10 Mei 2027'), findsOneWidget);
    // Siklus berjalan sampai siklus 25 Apr – 24 Mei: 7 siklus.
    expect(find.text('Perlu disisihkan Rp 428.572 per siklus selama 7 siklus.'), findsOneWidget);
    await tap(tester, find.widgetWithText(ChoiceChip, 'Tabungan'));
    await tap(tester, find.text('Simpan'));

    expect(find.text('Target Liburan ditambahkan.'), findsOneWidget);
    expect(find.text('Sisihkan Rp 428.572 lagi siklus ini'), findsOneWidget);

    // Setor dari BCA (pilihan bawaan): tercatat sebagai transfer.
    await tap(tester, find.text('Liburan'));
    expect(find.text('Tenggat 10 Mei 2027 · 7 siklus lagi · disimpan di Tabungan'), findsOneWidget);
    expect(find.text('Dicatat sebagai transfer ke Tabungan.'), findsOneWidget);
    await tap(tester, find.widgetWithText(FilledButton, 'Setor'));

    expect(find.text('Setoran Rp 428.572 ke Liburan dicatat.'), findsOneWidget);
    expect(find.text('Setoran siklus ini terpenuhi'), findsOneWidget);
    expect(find.text('Rp 2.571.428'), findsOneWidget); // BCA
    expect(find.text('Rp 428.572'), findsNWidgets(2)); // saldo Tabungan dan terkumpul

    // Uang yang sudah ada di rekening tujuan: setoran tanpa transfer.
    await tap(tester, find.text('Liburan'));
    await enterAmount(tester, '100000');
    await tap(tester, find.widgetWithText(ChoiceChip, 'Sudah di Tabungan'));
    expect(find.text('Hanya dicatat sebagai setoran, tanpa transfer.'), findsOneWidget);
    await tap(tester, find.widgetWithText(FilledButton, 'Setor'));

    expect(find.text('Rp 2.571.428'), findsOneWidget);
    expect(find.text('Rp 528.572'), findsOneWidget);
    final transfers = await (db.select(
      db.transactions,
    )..where((t) => t.type.equalsValue(TransactionType.transfer))).get();
    expect(transfers.single.amount, 428572);
    expect(transfers.single.note, 'Tabungan Liburan');

    // Ubah target dari detail: editor terbuka dengan isian lama.
    await tap(tester, find.text('Liburan'));
    await tap(tester, find.text('Ubah target'));
    expect(find.text('Ubah target'), findsOneWidget);
    expect(find.text('Tenggat 10 Mei 2027'), findsOneWidget);
    await enterText(tester, amountField('target'), '6000000');
    expect(find.text('Perlu disisihkan Rp 857.143 per siklus selama 7 siklus.'), findsOneWidget);
    await tap(tester, find.text('Simpan'));

    expect(find.text('Perubahan Liburan disimpan.'), findsOneWidget);
    expect(find.text('Sisihkan Rp 328.571 lagi siklus ini'), findsOneWidget);

    // Hapus target: transfernya tetap ada sebagai transfer biasa.
    await tap(tester, find.text('Liburan'));
    await tap(tester, find.text('Hapus target'));
    expect(find.text('Hapus Liburan?'), findsOneWidget);
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('Liburan dihapus.'), findsOneWidget);
    expect(find.text('Liburan'), findsNothing);
    expect(await db.select(db.savingsGoals).get(), isEmpty);
    expect(await db.select(db.goalContributions).get(), isEmpty);
    expect(await db.select(db.transactions).get(), hasLength(2));

    await close(tester);
  });

  testWidgets('kategori: tambah dengan ikon dan warna, ubah nama, arsipkan', (tester) async {
    await setUpData();
    await pumpSettings(tester);

    await reveal(tester, find.text('10 pengeluaran · 3 pemasukan'));
    await tap(tester, find.text('Kategori transaksi'));
    expect(find.text('PENGELUARAN'), findsOneWidget);
    expect(find.text('Makan & minum'), findsOneWidget);

    await tester.tap(find.byTooltip('Tambah kategori pengeluaran'));
    await tester.pumpAndSettle();
    expect(find.text('Kategori pengeluaran baru'), findsOneWidget);
    final name = find.widgetWithText(TextField, 'Nama kategori');

    // Nama yang sama dengan kategori aktif ditolak, tanpa membedakan huruf besar.
    await enterText(tester, name, 'lainnya');
    expect(find.text('Sudah ada kategori dengan nama ini.'), findsOneWidget);
    expect(saveEnabled(tester), isFalse);

    await enterText(tester, name, 'Kopi');
    expect(find.text('Sudah ada kategori dengan nama ini.'), findsNothing);
    await tap(tester, find.byTooltip('Biru'));
    await tap(tester, find.byIcon(AppIcons.named('coffee')));
    await tap(tester, find.text('Simpan'));

    expect(find.text('Kopi ditambahkan.'), findsOneWidget);
    await reveal(tester, find.text('Buatan sendiri'));
    final kopi = (await CategoryRepository(db).active(type: CategoryType.expense))
        .singleWhere((c) => c.name == 'Kopi');
    expect(kopi.icon, 'coffee');
    expect(kopi.tone, Tone.blue);
    expect(kopi.isDefault, isFalse);

    await tap(tester, find.text('Kopi'));
    expect(find.text('Ubah kategori'), findsOneWidget);
    await enterText(tester, name, 'Ngopi');
    await tap(tester, find.text('Simpan'));
    expect(find.text('Perubahan Ngopi disimpan.'), findsOneWidget);

    // Jumlah di Pengaturan ikut bertambah.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await reveal(tester, find.text('11 pengeluaran · 3 pemasukan'));

    await tap(tester, find.text('Kategori transaksi'));
    await tap(tester, find.text('Ngopi'));
    await tap(tester, find.text('Arsipkan kategori'));
    expect(find.text('Arsipkan Ngopi?'), findsOneWidget);
    await tester.tap(find.text('Arsipkan'));
    await tester.pumpAndSettle();

    expect(find.text('Ngopi diarsipkan.'), findsOneWidget);
    expect(find.text('Ngopi'), findsNothing);
    final archived = await (db.select(
      db.categories,
    )..where((c) => c.name.equals('Ngopi'))).getSingle();
    expect(archived.archived, isTrue);

    await close(tester);
  });
}
