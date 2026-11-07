import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/model/account_type_defaults.dart';
import '../../../core/model/enums.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/obligation_repository.dart';
import '../../../data/repositories/pay_cycle_repository.dart';
import '../../../engine/common/local_date.dart';
import 'onboarding_draft.dart';

/// Isian onboarding yang sedang diisi. Tidak ada yang ditulis ke database
/// sebelum pengguna menekan "Mulai pakai" di layar aha.
class OnboardingController extends Notifier<OnboardingDraft> {
  var _nextAccountId = 1;

  @override
  OnboardingDraft build() => const OnboardingDraft(
    accounts: [AccountDraft(id: 0, name: 'Rekening utama', type: AccountType.bank)],
  );

  void setPaydayRule(PaydayRule rule) => state = state.copyWith(paydayRule: rule);

  void setPayday(int day) => state = state.copyWith(payday: day);

  void setShiftOnHoliday(bool shift) => state = state.copyWith(shiftOnHoliday: shift);

  void setExpectedIncome(int amount) => state = state.copyWith(expectedIncome: amount);

  void addAccount(AccountType type) => state = state.copyWith(
    accounts: [
      ...state.accounts,
      AccountDraft(id: _nextAccountId++, name: type.defaultName, type: type),
    ],
  );

  void updateAccount(AccountDraft account) => state = state.copyWith(
    accounts: [for (final a in state.accounts) a.id == account.id ? account : a],
  );

  void removeAccount(int id) => state = state.copyWith(
    accounts: [
      for (final a in state.accounts)
        if (a.id != id) a,
    ],
  );

  void addObligation(ObligationDraft obligation) =>
      state = state.copyWith(obligations: [...state.obligations, obligation]);

  void replaceObligation(int index, ObligationDraft obligation) => state = state.copyWith(
    obligations: [for (final (i, o) in state.obligations.indexed) i == index ? obligation : o],
  );

  void removeObligation(int index) => state = state.copyWith(
    obligations: [
      for (final (i, o) in state.obligations.indexed)
        if (i != index) o,
    ],
  );
}

final onboardingControllerProvider = NotifierProvider<OnboardingController, OnboardingDraft>(
  OnboardingController.new,
);

/// Angka layar aha, dihitung ulang setiap isian berubah.
final onboardingPreviewProvider = Provider<OnboardingPreview>((ref) {
  final draft = ref.watch(onboardingControllerProvider);
  final today = LocalDate.fromDateTime(ref.watch(clockProvider)());
  return previewOnboarding(draft, today: today, holidays: ref.watch(holidayCalendarProvider));
});

/// Menyimpan hasil onboarding dalam satu transaksi.
class OnboardingService {
  OnboardingService({
    required this._db,
    required this._accounts,
    required this._categories,
    required this._obligations,
    required this._payCycles,
  });

  final AppDatabase _db;
  final AccountRepository _accounts;
  final CategoryRepository _categories;
  final ObligationRepository _obligations;
  final PayCycleRepository _payCycles;

  /// Aturan gajian ditulis paling akhir: begitu ada, pengguna dianggap sudah
  /// onboarding dan router pindah ke Beranda. Karena semuanya satu transaksi,
  /// Beranda tidak pernah melihat data setengah jadi.
  Future<void> complete(OnboardingDraft draft, {required LocalDate today}) {
    if (!draft.isComplete) throw ArgumentError.value(draft, 'draft', 'isian belum lengkap');
    return _db.transaction(() async {
      for (final account in draft.accounts) {
        await _accounts.create(
          name: account.name,
          type: account.type,
          icon: account.type.iconName,
          tone: account.type.tone,
          initialBalance: account.balance,
          includeInSafeToSpend: account.includeInSafeToSpend,
        );
      }

      final categories = await _categories.active(type: CategoryType.expense);
      int categoryId(String name) =>
          (categories.where((c) => c.name == name).firstOrNull ??
                  categories.where((c) => c.name == fallbackObligationCategory).firstOrNull ??
                  categories.first)
              .id;
      for (final obligation in draft.obligations) {
        await _obligations.create(
          name: obligation.name,
          amountType: obligation.amountType,
          amount: obligation.amount,
          dueDay: obligation.dueDay,
          categoryId: categoryId(obligation.categoryName),
          startsOn: today,
        );
      }

      await _payCycles.save(
        rule: draft.rule,
        expectedIncome: draft.expectedIncome,
        trackingSince: today,
      );
    });
  }
}

final onboardingServiceProvider = Provider<OnboardingService>(
  (ref) => OnboardingService(
    db: ref.watch(appDatabaseProvider),
    accounts: ref.watch(accountRepositoryProvider),
    categories: ref.watch(categoryRepositoryProvider),
    obligations: ref.watch(obligationRepositoryProvider),
    payCycles: ref.watch(payCycleRepositoryProvider),
  ),
);
