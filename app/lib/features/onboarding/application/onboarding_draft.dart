import '../../../core/model/enums.dart';
import '../../../engine/common/local_date.dart';
import '../../../engine/cycle/holiday_calendar.dart';
import '../../../engine/cycle/obligation_schedule.dart';
import '../../../engine/cycle/pay_cycle.dart';
import '../../../engine/safe_to_spend/safe_to_spend.dart';

/// Template kewajiban yang paling umum (Figma layar 02). Kategorinya merujuk
/// ke kategori bawaan berdasarkan nama.
final class ObligationTemplate {
  const ObligationTemplate(
    this.name,
    this.categoryName, {
    this.amountType = ObligationAmountType.fixed,
  });

  final String name;
  final String categoryName;
  final ObligationAmountType amountType;
}

const obligationTemplates = <ObligationTemplate>[
  ObligationTemplate('Kos', 'Tempat tinggal'),
  ObligationTemplate('Cicilan motor', 'Cicilan'),
  ObligationTemplate('Listrik', 'Tagihan & utilitas', amountType: ObligationAmountType.estimated),
  ObligationTemplate('Internet', 'Tagihan & utilitas'),
  ObligationTemplate('BPJS', 'Kesehatan'),
  ObligationTemplate('Streaming', 'Hiburan'),
  ObligationTemplate('Kiriman ortu', 'Lainnya'),
  ObligationTemplate('Pulsa & data', 'Tagihan & utilitas'),
];

/// Kategori untuk kewajiban di luar template.
const fallbackObligationCategory = 'Lainnya';

/// Akun yang diisi saat onboarding. [id] hanya untuk menjaga identitas
/// baris di layar, bukan id database.
final class AccountDraft {
  const AccountDraft({
    required this.id,
    required this.name,
    required this.type,
    this.balance = 0,
    this.includeInSafeToSpend = true,
  });

  final int id;
  final String name;
  final AccountType type;
  final int balance;
  final bool includeInSafeToSpend;

  bool get isValid => name.trim().isNotEmpty && balance >= 0;

  AccountDraft copyWith({String? name, int? balance, bool? includeInSafeToSpend}) => AccountDraft(
    id: id,
    name: name ?? this.name,
    type: type,
    balance: balance ?? this.balance,
    includeInSafeToSpend: includeInSafeToSpend ?? this.includeInSafeToSpend,
  );
}

/// Kewajiban yang diisi saat onboarding.
final class ObligationDraft {
  const ObligationDraft({
    required this.name,
    required this.amount,
    required this.dueDay,
    required this.categoryName,
    this.amountType = ObligationAmountType.fixed,
  });

  final String name;
  final int amount;
  final int dueDay;
  final String categoryName;
  final ObligationAmountType amountType;

  bool get isValid => name.trim().isNotEmpty && amount > 0 && dueDay >= 1 && dueDay <= 31;

  ObligationDraft copyWith({
    String? name,
    int? amount,
    int? dueDay,
    String? categoryName,
    ObligationAmountType? amountType,
  }) => ObligationDraft(
    name: name ?? this.name,
    amount: amount ?? this.amount,
    dueDay: dueDay ?? this.dueDay,
    categoryName: categoryName ?? this.categoryName,
    amountType: amountType ?? this.amountType,
  );
}

/// Semua isian onboarding sebelum disimpan (PRD §8.1).
final class OnboardingDraft {
  const OnboardingDraft({
    this.paydayRule = PaydayRule.fixedDate,
    this.payday = 25,
    this.shiftOnHoliday = true,
    this.expectedIncome = 0,
    this.accounts = const [],
    this.obligations = const [],
  });

  final PaydayRule paydayRule;

  /// Tanggal gajian (1–31) untuk aturan tanggal tetap.
  final int payday;
  final bool shiftOnHoliday;
  final int expectedIncome;
  final List<AccountDraft> accounts;
  final List<ObligationDraft> obligations;

  PayCycleRule get rule => switch (paydayRule) {
    PaydayRule.fixedDate => PayCycleRule.fixedDate(payday, shiftOnHoliday: shiftOnHoliday),
    PaydayRule.lastWorkday => const PayCycleRule.lastWorkday(),
  };

  bool get isPaydayStepValid => expectedIncome > 0;

  bool get isAccountsStepValid =>
      accounts.isNotEmpty && accounts.every((account) => account.isValid);

  bool get isObligationsStepValid => obligations.every((obligation) => obligation.isValid);

  bool get isComplete => isPaydayStepValid && isAccountsStepValid && isObligationsStepValid;

  /// Saldo akun yang ikut dihitung di Safe-to-Spend.
  int get countedBalance => accounts
      .where((account) => account.includeInSafeToSpend)
      .fold(0, (sum, account) => sum + account.balance);

  bool get hasExcludedAccount => accounts.any((account) => !account.includeInSafeToSpend);

  int get monthlyObligations => obligations.fold(0, (sum, obligation) => sum + obligation.amount);

  OnboardingDraft copyWith({
    PaydayRule? paydayRule,
    int? payday,
    bool? shiftOnHoliday,
    int? expectedIncome,
    List<AccountDraft>? accounts,
    List<ObligationDraft>? obligations,
  }) => OnboardingDraft(
    paydayRule: paydayRule ?? this.paydayRule,
    payday: payday ?? this.payday,
    shiftOnHoliday: shiftOnHoliday ?? this.shiftOnHoliday,
    expectedIncome: expectedIncome ?? this.expectedIncome,
    accounts: accounts ?? this.accounts,
    obligations: obligations ?? this.obligations,
  );
}

/// Angka layar aha: Safe-to-Spend pertama dan rinciannya.
final class OnboardingPreview {
  const OnboardingPreview({
    required this.cycle,
    required this.safeToSpend,
    required this.protectedCount,
  });

  final PayCycle cycle;
  final SafeToSpend safeToSpend;

  /// Jumlah jatuh tempo yang dicadangkan sampai gajian berikutnya.
  final int protectedCount;
}

/// Menghitung Safe-to-Spend dari isian onboarding dengan aturan yang sama
/// seperti `SafeToSpendService` setelah data disimpan: saldo awal, jatuh tempo
/// mulai hari ini sampai gajian berikutnya, tanpa target tabungan, buffer
/// bawaan. Test memastikan keduanya selalu sama.
OnboardingPreview previewOnboarding(
  OnboardingDraft draft, {
  required LocalDate today,
  required HolidayCalendar holidays,
}) {
  final cycle = PayCycleCalculator(draft.rule, holidays: holidays).cycleContaining(today);
  final dues = [
    for (final obligation in draft.obligations)
      for (final due in monthlyDueDatesBetween(obligation.dueDay, today, cycle.nextPayday))
        ObligationDue(dueDate: due, expectedAmount: obligation.amount),
  ];
  return OnboardingPreview(
    cycle: cycle,
    safeToSpend: calculateSafeToSpend(
      availableBalance: draft.countedBalance,
      obligationsReserved: reservedForObligations(dues, cycle.nextPayday),
      daysLeft: cycle.daysLeft(today),
    ),
    protectedCount: dues.length,
  );
}
