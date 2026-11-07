import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/app.dart';
import 'package:keuangan_app/core/widgets/day_of_month_grid.dart';
import 'package:keuangan_app/core/widgets/rupiah_field.dart';
import 'package:keuangan_app/data/db/app_database.dart';
import 'package:keuangan_app/data/db/database_provider.dart';
import 'package:keuangan_app/data/providers.dart';
import 'package:keuangan_app/engine/cycle/holiday_calendar.dart';

void main() {
  testWidgets('pengguna baru menyelesaikan onboarding lalu melihat angka yang sama di Beranda', (
    tester,
  ) async {
    // Layar 360 × 800 dp seperti frame Figma.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final db = AppDatabase(NativeDatabase.memory());
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

    // Isi layar memakai ListView yang membangun isinya saat di-scroll, jadi
    // elemen di bawah lipatan perlu di-scroll dulu sebelum bisa ditemukan.
    Future<void> reveal(Finder target) async {
      if (target.evaluate().isEmpty) {
        await tester.scrollUntilVisible(target, 120, scrollable: find.byType(Scrollable).first);
      }
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
    }

    Future<void> tapText(String text) async {
      await reveal(find.text(text));
      await tester.tap(find.text(text).last);
      await tester.pumpAndSettle();
    }

    Future<void> enterAmount(Finder field, String digits) async {
      await reveal(field);
      await tester.enterText(find.descendant(of: field, matching: find.byType(TextField)), digits);
      await tester.pumpAndSettle();
    }

    // 1. Siklus gajian: tanggal 25 sudah terpilih.
    expect(find.text('Kapan kamu gajian?'), findsOneWidget);
    await reveal(find.text('Gajian berikutnya Rab, 25 Nov · 14 hari lagi'));
    await enterAmount(find.byType(RupiahField), '7500000');
    expect(find.text('7.500.000'), findsOneWidget);
    await tapText('Lanjut');

    // 2. Saldo
    expect(find.text('Berapa uangmu sekarang?'), findsOneWidget);
    await enterAmount(find.byType(RupiahField), '3000000');
    expect(find.text('Rp 3.000.000'), findsOneWidget);
    await tapText('Lanjut');

    // 3. Kewajiban dari template
    expect(find.text('Apa saja kewajiban rutinmu?'), findsOneWidget);
    Future<void> addTemplate(String name, String digits, {int? dueDay}) async {
      await tapText(name);
      expect(find.text('Tambah kewajiban'), findsOneWidget);
      await enterAmount(find.byType(RupiahField).last, digits);
      if (dueDay != null) {
        final cell = find.descendant(
          of: find.byType(DayOfMonthGrid).last,
          matching: find.text('$dueDay'),
        );
        await reveal(cell);
        await tester.tap(cell);
        await tester.pumpAndSettle();
      }
      await tapText('Simpan');
    }

    await addTemplate('Kos', '1000000');
    await addTemplate('Cicilan motor', '850000');
    await addTemplate('Listrik', '350000', dueDay: 20);
    expect(find.text('DIPILIH (3)'), findsOneWidget);
    expect(find.text('Tiap tanggal 20 · estimasi'), findsOneWidget);
    expect(find.text('Rp 2.200.000'), findsOneWidget);
    await tapText('Lanjut');

    // 4. Aha: kartu dan rincian menunjukkan angka Lampiran A PRD.
    expect(find.text('Ini uang yang aman kamu belanjakan'), findsOneWidget);
    expect(find.text('Rp 760.000'), findsNWidgets(2));
    expect(find.text('−Rp 2.200.000'), findsOneWidget);
    expect(find.text('−Rp 40.000'), findsOneWidget);
    await tapText('Mulai pakai Moneytoring');

    // Beranda menghitung ulang dari database dan hasilnya sama.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Rp 760.000'), findsOneWidget);
    expect(find.text('Jatah harian Rp 54.285'), findsOneWidget);
    expect(find.text('Rp 2,2 jt diamankan untuk 3 kewajiban'), findsOneWidget);

    // Lepas aplikasi dulu, majukan waktu palsu supaya timer penutup stream
    // Drift sempat jalan, baru tutup database di luar waktu palsu.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(db.close);
  });
}
