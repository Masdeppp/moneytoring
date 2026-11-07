import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/model/enums.dart';
import '../engine/common/local_date.dart';
import '../engine/cycle/holiday_calendar.dart';
import '../engine/cycle/indonesia_holidays.dart';
import 'db/app_database.dart';
import 'db/database_provider.dart';
import 'repositories/account_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/obligation_repository.dart';
import 'repositories/pay_cycle_repository.dart';
import 'repositories/savings_repository.dart';
import 'repositories/transaction_repository.dart';
import 'services/safe_to_spend_service.dart';

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

/// Kategori pengeluaran aktif, urut seperti di pengaturan.
final expenseCategoriesProvider = StreamProvider<List<CategoryRecord>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchActive(type: CategoryType.expense),
);

/// Angka kartu Safe-to-Spend di Beranda, diperbarui setiap data berubah.
/// `null` sebelum onboarding selesai.
final safeToSpendProvider = StreamProvider<SafeToSpendSnapshot?>((ref) {
  final service = ref.watch(safeToSpendServiceProvider);
  final clock = ref.watch(clockProvider);
  return service.watch(() => LocalDate.fromDateTime(clock()));
});
