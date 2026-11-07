import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuangan_app/core/model/enums.dart';
import 'package:keuangan_app/data/db/app_database.dart';
import 'package:keuangan_app/data/db/database_provider.dart';
import 'package:keuangan_app/data/providers.dart';
import 'package:keuangan_app/engine/common/local_date.dart';
import 'package:keuangan_app/engine/cycle/holiday_calendar.dart';
import 'package:keuangan_app/engine/cycle/indonesia_holidays.dart';
import 'package:keuangan_app/features/onboarding/application/onboarding_controller.dart';
import 'package:keuangan_app/features/onboarding/application/onboarding_draft.dart';

void main() {
  final today = LocalDate(2026, 11, 11);
  const noHolidays = NoHolidays();

  /// Lampiran A PRD sebagai isian onboarding.
  OnboardingDraft lampiranA({bool shiftOnHoliday = false}) => OnboardingDraft(
    shiftOnHoliday: shiftOnHoliday,
    expectedIncome: 7500000,
    accounts: const [
      AccountDraft(id: 0, name: 'BCA', type: AccountType.bank, balance: 3000000),
      AccountDraft(
        id: 1,
        name: 'Dana darurat',
        type: AccountType.bank,
        balance: 10000000,
        includeInSafeToSpend: false,
      ),
    ],
    obligations: const [
      ObligationDraft(
        name: 'Listrik',
        amount: 350000,
        dueDay: 20,
        categoryName: 'Tagihan & utilitas',
        amountType: ObligationAmountType.estimated,
      ),
      ObligationDraft(name: 'Cicilan motor', amount: 850000, dueDay: 25, categoryName: 'Cicilan'),
      ObligationDraft(name: 'Kos', amount: 1000000, dueDay: 25, categoryName: 'Tempat tinggal'),
    ],
  );

  group('OnboardingDraft', () {
    test('validasi per langkah', () {
      const empty = OnboardingDraft();
      expect(empty.isPaydayStepValid, isFalse);
      expect(empty.isAccountsStepValid, isFalse);
      expect(empty.isComplete, isFalse);

      final draft = lampiranA();
      expect(draft.isComplete, isTrue);
      expect(
        draft.copyWith(accounts: [draft.accounts.first.copyWith(name: '  ')]).isAccountsStepValid,
        isFalse,
      );
      expect(
        draft.copyWith(obligations: [draft.obligations.first.copyWith(amount: 0)]).isComplete,
        isFalse,
      );
    });

    test('saldo yang dihitung tidak memasukkan dana darurat', () {
      final draft = lampiranA();
      expect(draft.countedBalance, 3000000);
      expect(draft.hasExcludedAccount, isTrue);
      expect(draft.monthlyObligations, 2200000);
    });

    test('aturan gajian mengikuti isian', () {
      final fixed = lampiranA().rule;
      expect(fixed.rule, PaydayRule.fixedDate);
      expect(fixed.day, 25);
      expect(fixed.shiftOnHoliday, isFalse);
      expect(
        lampiranA().copyWith(paydayRule: PaydayRule.lastWorkday).rule.rule,
        PaydayRule.lastWorkday,
      );
    });
  });

  group('previewOnboarding', () {
    test('Lampiran A PRD: Rp 760.000, 3 jatuh tempo dicadangkan', () {
      final preview = previewOnboarding(lampiranA(), today: today, holidays: noHolidays);

      expect(preview.cycle.nextPayday, LocalDate(2026, 11, 25));
      expect(preview.safeToSpend.availableBalance, 3000000);
      expect(preview.safeToSpend.obligationsReserved, 2200000);
      expect(preview.safeToSpend.amount, 760000);
      expect(preview.safeToSpend.dailyAllowance, 54285);
      expect(preview.protectedCount, 3);
    });

    test('jatuh tempo yang sudah lewat bulan ini tidak dicadangkan', () {
      final draft = lampiranA().copyWith(
        obligations: const [
          ObligationDraft(name: 'Gym', amount: 300000, dueDay: 1, categoryName: 'Kesehatan'),
        ],
      );
      final preview = previewOnboarding(draft, today: today, holidays: noHolidays);
      expect(preview.safeToSpend.obligationsReserved, 0);
      expect(preview.protectedCount, 0);
    });
  });

  group('OnboardingController', () {
    late ProviderContainer container;
    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    OnboardingController controller() => container.read(onboardingControllerProvider.notifier);
    OnboardingDraft draft() => container.read(onboardingControllerProvider);

    test('dimulai dengan satu rekening, gajian tanggal 25', () {
      expect(draft().accounts.single.name, 'Rekening utama');
      expect(draft().payday, 25);
      expect(draft().paydayRule, PaydayRule.fixedDate);
    });

    test('mengubah aturan gajian', () {
      controller()
        ..setPaydayRule(PaydayRule.lastWorkday)
        ..setPayday(1)
        ..setShiftOnHoliday(false)
        ..setExpectedIncome(6000000);
      expect(draft().paydayRule, PaydayRule.lastWorkday);
      expect(draft().payday, 1);
      expect(draft().shiftOnHoliday, isFalse);
      expect(draft().isPaydayStepValid, isTrue);
    });

    test('menambah, mengubah, dan menghapus akun', () {
      controller().addAccount(AccountType.ewallet);
      final added = draft().accounts.last;
      expect(added.name, 'E-wallet');
      expect(added.id, isNot(draft().accounts.first.id));

      controller().updateAccount(added.copyWith(name: 'GoPay', balance: 150000));
      expect(draft().accounts.last.name, 'GoPay');
      expect(draft().countedBalance, 150000);

      controller().removeAccount(added.id);
      expect(draft().accounts, hasLength(1));
    });

    test('menambah, mengganti, dan menghapus kewajiban', () {
      const kos = ObligationDraft(
        name: 'Kos',
        amount: 1000000,
        dueDay: 25,
        categoryName: 'Tempat tinggal',
      );
      controller()
        ..addObligation(kos)
        ..addObligation(kos.copyWith(name: 'Internet', amount: 350000))
        ..replaceObligation(0, kos.copyWith(amount: 1200000));
      expect(draft().obligations.map((o) => o.amount), [1200000, 350000]);

      controller().removeObligation(0);
      expect(draft().obligations.single.name, 'Internet');
    });
  });

  group('OnboardingService', () {
    late AppDatabase db;
    late ProviderContainer container;

    ProviderContainer containerWith(HolidayCalendar holidays) => ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 11, 10)),
        holidayCalendarProvider.overrideWithValue(holidays),
      ],
    );

    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() async {
      container.dispose();
      await db.close();
    });

    for (final (label, shift, holidays) in [
      ('tanpa geser', false, noHolidays),
      ('geser libur nasional', true, indonesiaNationalHolidays),
    ]) {
      test('angka di Beranda setelah disimpan sama dengan pratinjau ($label)', () async {
        container = containerWith(holidays);
        final draft = lampiranA(shiftOnHoliday: shift);
        final preview = previewOnboarding(draft, today: today, holidays: holidays);

        // Riverpod 3 menjeda stream provider tanpa listener; dengarkan dulu.
        final status = container.listen(onboardingStatusProvider, (_, _) {});
        addTearDown(status.close);
        expect(await container.read(onboardingStatusProvider.future), isFalse);
        await container.read(onboardingServiceProvider).complete(draft, today: today);
        final snapshot = (await container.read(safeToSpendServiceProvider).compute(today))!;

        expect(snapshot.cycle, preview.cycle);
        expect(snapshot.safeToSpend.availableBalance, preview.safeToSpend.availableBalance);
        expect(snapshot.safeToSpend.obligationsReserved, preview.safeToSpend.obligationsReserved);
        expect(snapshot.safeToSpend.buffer, preview.safeToSpend.buffer);
        expect(snapshot.safeToSpend.amount, preview.safeToSpend.amount);
        expect(snapshot.safeToSpend.dailyAllowance, preview.safeToSpend.dailyAllowance);
        expect(snapshot.protectedCount, preview.protectedCount);
      });
    }

    test('akun, kewajiban, dan aturan gajian tersimpan lengkap', () async {
      container = containerWith(noHolidays);
      await container.read(onboardingServiceProvider).complete(lampiranA(), today: today);

      final accounts = await db.select(db.accounts).get();
      expect(accounts.map((a) => a.name), ['BCA', 'Dana darurat']);
      expect(accounts.first.icon, 'landmark');
      expect(accounts.first.tone, Tone.blue);
      expect(accounts.last.includeInSafeToSpend, isFalse);

      final categories = {for (final c in await db.select(db.categories).get()) c.id: c.name};
      final obligations = await db.select(db.obligations).get();
      expect(
        {for (final o in obligations) o.name: categories[o.categoryId]},
        {'Listrik': 'Tagihan & utilitas', 'Cicilan motor': 'Cicilan', 'Kos': 'Tempat tinggal'},
      );
      expect(obligations.first.amountType, ObligationAmountType.estimated);
      expect(obligations.map((o) => LocalDate.fromDateTime(o.startsOn)).toSet(), {today});

      final config = await db.select(db.payCycleConfigs).getSingle();
      expect(config.day, 25);
      expect(config.expectedIncome, 7500000);
      expect(LocalDate.fromDateTime(config.trackingSince), today);
    });

    test('kategori yang tidak dikenal masuk ke "Lainnya"; isian belum lengkap ditolak', () async {
      container = containerWith(noHolidays);
      final service = container.read(onboardingServiceProvider);
      expect(() => service.complete(const OnboardingDraft(), today: today), throwsArgumentError);

      await service.complete(
        lampiranA().copyWith(
          obligations: const [
            ObligationDraft(name: 'Arisan', amount: 200000, dueDay: 15, categoryName: 'Arisan'),
          ],
        ),
        today: today,
      );
      final obligation = await db.select(db.obligations).getSingle();
      final category = await (db.select(
        db.categories,
      )..where((c) => c.id.equals(obligation.categoryId))).getSingle();
      expect(category.name, fallbackObligationCategory);
    });
  });
}
