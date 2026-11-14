import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/model/enums.dart';
import '../engine/common/local_date.dart';
import '../engine/cycle/holiday_calendar.dart';
import '../engine/cycle/indonesia_holidays.dart';
import '../engine/cycle/pay_cycle.dart';
import '../engine/safe_to_spend/savings_goal.dart';
import 'db/app_database.dart';
import 'db/database_provider.dart';
import 'repositories/account_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/obligation_repository.dart';
import 'repositories/pay_cycle_repository.dart';
import 'repositories/savings_repository.dart';
import 'repositories/transaction_repository.dart';
import 'services/safe_to_spend_service.dart';
import 'services/salary_share_service.dart';

/// Jam aplikasi. Di test di-override supaya "hari ini" tetap.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Libur nasional untuk menggeser tanggal gajian.
final holidayCalendarProvider = Provider<HolidayCalendar>((ref) => indonesiaNationalHolidays);

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(ref.watch(appDatabaseProvider)),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.watch(appDatabaseProvider)),
);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(ref.watch(appDatabaseProvider)),
);

final obligationRepositoryProvider = Provider<ObligationRepository>(
  (ref) => ObligationRepository(ref.watch(appDatabaseProvider)),
);

final payCycleRepositoryProvider = Provider<PayCycleRepository>(
  (ref) => PayCycleRepository(ref.watch(appDatabaseProvider)),
);

final savingsRepositoryProvider = Provider<SavingsRepository>(
  (ref) => SavingsRepository(ref.watch(appDatabaseProvider)),
);

final safeToSpendServiceProvider = Provider<SafeToSpendService>(
  (ref) => SafeToSpendService(
    db: ref.watch(appDatabaseProvider),
    holidays: ref.watch(holidayCalendarProvider),
    accounts: ref.watch(accountRepositoryProvider),
    transactions: ref.watch(transactionRepositoryProvider),
    obligations: ref.watch(obligationRepositoryProvider),
    payCycles: ref.watch(payCycleRepositoryProvider),
    savings: ref.watch(savingsRepositoryProvider),
  ),
);

/// `true` setelah onboarding selesai (aturan gajian sudah tersimpan).
/// Router memakai ini untuk memilih antara onboarding dan Beranda.
final onboardingStatusProvider = StreamProvider<bool>(
  (ref) => ref.watch(payCycleRepositoryProvider).watch().map((config) => config != null),
);

/// Aturan gajian yang tersimpan (Pengaturan); `null` sebelum onboarding.
final payCycleConfigProvider = StreamProvider<PayCycleConfigRecord?>(
  (ref) => ref.watch(payCycleRepositoryProvider).watch(),
);

/// Kalkulator siklus dari aturan gajian; `null` sebelum onboarding.
final payCycleCalculatorProvider = Provider<PayCycleCalculator?>((ref) {
  final config = ref.watch(payCycleConfigProvider).value;
  if (config == null) return null;
  return PayCycleCalculator(
    PayCycleRepository.ruleOf(config),
    holidays: ref.watch(holidayCalendarProvider),
  );
});

/// Target tabungan aktif dengan rencana siklus berjalan (Pengaturan).
final savingsGoalsProvider =
    StreamProvider<List<({SavingsGoalProgress goal, SavingsGoalPlan plan})>>((ref) {
      final config = ref.watch(payCycleConfigProvider).value;
      final calculator = ref.watch(payCycleCalculatorProvider);
      if (config == null || calculator == null) return Stream.value(const []);
      final cycle = calculator.cycleContaining(LocalDate.fromDateTime(ref.watch(clockProvider)()));
      return ref
          .watch(savingsRepositoryProvider)
          .watchProgress(cycle.start)
          .map(
            (goals) => [
              for (final goal in goals)
                (
                  goal: goal,
                  plan: planGoal(
                    goal,
                    calculator: calculator,
                    cycle: cycle,
                    expectedIncome: config.expectedIncome,
                  ),
                ),
            ],
          );
    });

/// Sisihan persen gaji: mengatur persen dan melepas tabungan "Sisa gaji".
final salaryShareServiceProvider = Provider<SalaryShareService>(
  (ref) => SalaryShareService(
    holidays: ref.watch(holidayCalendarProvider),
    accounts: ref.watch(accountRepositoryProvider),
    obligations: ref.watch(obligationRepositoryProvider),
    payCycles: ref.watch(payCycleRepositoryProvider),
    savings: ref.watch(savingsRepositoryProvider),
  ),
);

/// Riwayat setoran satu target, terbaru dulu (Pengaturan → detail target).
final goalContributionsProvider = StreamProvider.autoDispose
    .family<List<GoalContributionRecord>, int>(
      (ref, goalId) => ref.watch(savingsRepositoryProvider).watchContributions(goalId),
    );

/// Semua kategori aktif (Pengaturan → Kategori).
final activeCategoriesProvider = StreamProvider<List<CategoryRecord>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchActive(),
);

/// Kategori pengeluaran aktif, urut seperti di pengaturan.
final expenseCategoriesProvider = StreamProvider<List<CategoryRecord>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchActive(type: CategoryType.expense),
);

/// Semua kategori (termasuk arsip), untuk mencari ikon dan nama dari id.
final allCategoriesProvider = StreamProvider<List<CategoryRecord>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);

/// Akun aktif beserta saldonya.
final accountBalancesProvider = StreamProvider<List<AccountBalance>>(
  (ref) => ref.watch(accountRepositoryProvider).watchBalances(),
);

/// Tiga transaksi terbaru untuk Beranda.
final recentTransactionsProvider = StreamProvider<List<TransactionView>>(
  (ref) => ref.watch(transactionRepositoryProvider).watchRecent(limit: 3),
);

/// Daftar transaksi layar 07 untuk satu filter dan jumlah baris yang sudah
/// dimuat. Dibuang begitu layar tidak lagi memakainya, supaya tiap kata
/// pencarian tidak meninggalkan query yang terus diawasi.
final transactionListProvider = StreamProvider.autoDispose
    .family<List<TransactionView>, ({TransactionFilter filter, int limit})>(
      (ref, key) =>
          ref.watch(transactionRepositoryProvider).watchFiltered(key.filter, limit: key.limit),
    );

/// Siklus gajian yang memuat hari ini; `null` sebelum onboarding.
final currentCycleProvider = StreamProvider<PayCycle?>((ref) {
  final holidays = ref.watch(holidayCalendarProvider);
  final today = LocalDate.fromDateTime(ref.watch(clockProvider)());
  return ref
      .watch(payCycleRepositoryProvider)
      .watch()
      .map(
        (config) => config == null
            ? null
            : PayCycleCalculator(
                PayCycleRepository.ruleOf(config),
                holidays: holidays,
              ).cycleContaining(today),
      );
});

/// Timeline kewajiban siklus berjalan (layar 08), termasuk yang terlambat
/// dari siklus sebelumnya. `null` sebelum onboarding.
final cycleObligationsProvider = StreamProvider<({PayCycle cycle, List<ObligationDueView> dues})?>((
  ref,
) {
  final cycle = ref.watch(currentCycleProvider).value;
  if (cycle == null) return Stream.value(null);
  return ref
      .watch(obligationRepositoryProvider)
      .watchCycle(cycle)
      .map((dues) => (cycle: cycle, dues: dues));
});

/// Semua kewajiban aktif, urut tanggal jatuh tempo (layar 08, "Semua kewajiban").
final activeObligationsProvider = StreamProvider<List<ObligationRecord>>(
  (ref) => ref.watch(obligationRepositoryProvider).watchActive(),
);

/// Pemasukan dan pengeluaran siklus berjalan (ringkasan layar 07).
final cycleTotalsProvider = StreamProvider<({PayCycle cycle, CashFlowTotals totals})?>((ref) {
  final cycle = ref.watch(currentCycleProvider).value;
  if (cycle == null) return Stream.value(null);
  return ref
      .watch(transactionRepositoryProvider)
      .watchTotals(cycle.start.toDateTime(), cycle.nextPayday.toDateTime())
      .map((totals) => (cycle: cycle, totals: totals));
});

/// Angka kartu Safe-to-Spend di Beranda, diperbarui setiap data berubah.
/// `null` sebelum onboarding selesai.
final safeToSpendProvider = StreamProvider<SafeToSpendSnapshot?>((ref) {
  final service = ref.watch(safeToSpendServiceProvider);
  final clock = ref.watch(clockProvider);
  return service.watch(() => LocalDate.fromDateTime(clock()));
});
